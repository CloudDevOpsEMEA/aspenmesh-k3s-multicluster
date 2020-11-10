#!/bin/bash

set -xEeuo pipefail

# Based on https://github.com/morvencao/kube-mutating-webhook-tutorial/blob/master/deployment/webhook-patch-ca-bundle.sh

while [[ $# -gt 0 ]]; do
    case ${1} in
        --service)
            service="$2"
            shift
            ;;
        --secret)
            secret="$2"
            shift
            ;;
        --namespace)
            namespace="$2"
            shift
            ;;
    esac
    shift
done

service=${service:-aspen-mesh-secure-ingress}
secret=${secret:-secure-ingress-webhook-certs}
namespace=${namespace:-istio-system}

csrName=${service}.${namespace}
tmpdir=$(mktemp -d)
echo "creating certs in tmpdir ${tmpdir} "

cat <<EOF >> "${tmpdir}/csr.conf"
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${service}
DNS.2 = ${service}.${namespace}
DNS.3 = ${service}.${namespace}.svc
EOF

openssl genrsa -out "${tmpdir}/server-key.pem" 2048
openssl req -new -key "${tmpdir}/server-key.pem" -subj "/CN=${service}.${namespace}.svc" -out "${tmpdir}/server.csr" -config "${tmpdir}/csr.conf"

# clean-up any previously created CSR for our service. Ignore errors if not present.
kubectl delete csr ${csrName} 2>/dev/null || true

# create  server cert/key CSR and  send to k8s API
cat <<EOF | kubectl create -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ${csrName}
spec:
  groups:
  - system:authenticated
  request: $(base64 "${tmpdir}/server.csr" | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

# verify CSR has been created
while true; do
  if kubectl get csr ${csrName}; then
    break
  fi
done

# approve and fetch the signed certificate
kubectl certificate approve ${csrName}
set +x
# verify certificate has been signed
for x in $(seq 10); do
    set -x
    echo "Attempt ${x} to verify certificate"
    set +x
    serverCert=$(kubectl get csr ${csrName} -o jsonpath='{.status.certificate}') || true
    if [[ ${serverCert} != '' ]]; then
        break
    fi
    sleep 1
done
if [[ ${serverCert} == '' ]]; then
    echo "ERROR: After approving csr ${csrName}, the signed certificate did not appear on the resource. Giving up after 10 attempts." >&2
    exit 1
fi
echo "${serverCert}" | openssl base64 -d -A -out "${tmpdir}/server-cert.pem"
set -x


# create the secret with CA cert and server cert/key
kubectl -v5 create secret generic ${secret} \
        --from-file=key.pem="${tmpdir}/server-key.pem" \
        --from-file='cert-chain.pem'="${tmpdir}/server-cert.pem" \
        -n ${namespace} \
        --dry-run -o yaml |
        kubectl apply -f -

CA_MARKER="__CABUNDLE__"
UID_MARKER="__UID__"
MOUNTED_WEBHOOK_CONFIG_PATH="/tmp/cert/webhook.yaml"
NEW_WEBHOOK_CONFIG_PATH="$HOME/webhook.yaml"

echo "Setting apiserver as CA"
echo "Setting Service UID"
set +x
KUBEAPI_CA=$(kubectl get configmap -n kube-system extension-apiserver-authentication -o=jsonpath='{.data.client-ca-file}' | base64 | tr -d '\n')
SERVICE_UID=$(kubectl get service ${service} -n "${namespace}" \
  -o jsonpath='{.metadata.uid}')

# Replace the caBundle and uid placeholders in the webhook config
cp "${MOUNTED_WEBHOOK_CONFIG_PATH}" "${NEW_WEBHOOK_CONFIG_PATH}"
sed -i "s/${CA_MARKER}/${KUBEAPI_CA}/g" "${NEW_WEBHOOK_CONFIG_PATH}"
sed -i "s/${UID_MARKER}/${SERVICE_UID}/g" "${NEW_WEBHOOK_CONFIG_PATH}"

set -x
# Apply the webhook configuration
kubectl apply -f "${NEW_WEBHOOK_CONFIG_PATH}"
