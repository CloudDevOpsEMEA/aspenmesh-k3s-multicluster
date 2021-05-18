#!/usr/bin/env bash

ROOT_DIR=$(pwd)
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster

source ${REPO_DIR}/environment.sh

AM_DIR=${REPO_DIR}/aspenmesh/aspenmesh-${AM_VERSION}
AM_HELM_CHART_DIR=${AM_DIR}/manifests/charts


if [[ $1 = "istioctl" ]]; then
  curl -sL https://istio.io/downloadIstioctl | ISTIO_VERSION=${ISTIO_VERSION} sh - && \
  sudo cp ~/.istioctl/bin/istioctl /usr/local/bin
  exit 0
fi

if [[ $2 = "cluster1" ]]; then
  KUBESPRAY_CLUSTER_NAME=${KUBESPRAY_CLUSTER1_NAME}
  AM_CLUSTER_NAME=${AM_CLUSTER1_NAME}
  AM_CLUSTER_NAME_REMOTE=${AM_CLUSTER2_NAME}
  AM_NETWORK=${AM_CLUSTER1_NETWORK}
  AM_CLUSTER_INGRESS_IP=${AM_CLUSTER1_INGRESS_IP}
  AM_SVC_DIR=${REPO_DIR}/install/aspenmesh/services/${AM_CLUSTER1_NAME}
elif [[ $2 = "cluster2" ]]; then
  KUBESPRAY_CLUSTER_NAME=${KUBESPRAY_CLUSTER2_NAME}
  AM_CLUSTER_NAME=${AM_CLUSTER2_NAME}
  AM_CLUSTER_NAME_REMOTE=${AM_CLUSTER1_NAME}
  AM_NETWORK=${AM_CLUSTER2_NETWORK}
  AM_CLUSTER_INGRESS_IP=${AM_CLUSTER2_INGRESS_IP}
  AM_SVC_DIR=${REPO_DIR}/install/aspenmesh/services/${AM_CLUSTER2_NAME}
else
  echo "please specify action ./aspenmesh.sh install/update/remove/istioctl/services cluster1/cluster2"
  exit 1
fi

AM_CERT_DIR=${REPO_DIR}/install/certs/${AM_CLUSTER_NAME}
AM_VALUES=${REPO_DIR}/install/aspenmesh/values-${AM_CLUSTER_NAME}.yaml
AM_MULTISECRET=${REPO_DIR}/install/aspenmesh/multisecrets/secret-${AM_CLUSTER_NAME}.yaml
AM_MULTISECRET_REMOTE=${REPO_DIR}/install/aspenmesh/multisecrets/secret-${AM_CLUSTER_NAME_REMOTE}.yaml

KUBECONFIG=${REPO_DIR}/install/kubespray/${KUBESPRAY_CLUSTER_NAME}-kubeconfig.yaml

KUBECTL="kubectl --kubeconfig=${KUBECONFIG}"
HELM="helm --kubeconfig=${KUBECONFIG}"
ISTIOCTL="istioctl --kubeconfig=${KUBECONFIG}"

PATCH_INGRESS_FILE=${REPO_DIR}/install/aspenmesh/patches/patch-ingress-${AM_CLUSTER_NAME}.yaml

function patch_service_ingress {
  echo "spec:" > ${PATCH_INGRESS_FILE}
  echo "  externalIPs:" >> ${PATCH_INGRESS_FILE}
  echo "    -  \"${AM_CLUSTER_INGRESS_IP}\"" >> ${PATCH_INGRESS_FILE}

  
  echo "${KUBECTL} patch svc -n istio-system istio-ingressgateway -p \"$(cat ${PATCH_INGRESS_FILE})\""
  ${KUBECTL} patch svc -n istio-system istio-ingressgateway -p "$(cat ${PATCH_INGRESS_FILE})"
}

if [[ $1 = "install" ]]; then
  ${KUBECTL} create ns ${AM_NAMESPACE}
  ${KUBECTL} label namespace ${AM_NAMESPACE} topology.istio.io/network=${AM_NETWORK}
  ${KUBECTL} create secret generic cacerts -n ${AM_NAMESPACE} \
    --from-file=${AM_CERT_DIR}/ca-cert.pem \
    --from-file=${AM_CERT_DIR}/ca-key.pem \
    --from-file=${AM_CERT_DIR}/root-cert.pem \
    --from-file=${AM_CERT_DIR}/cert-chain.pem
  ${HELM} install istio-base ${AM_HELM_CHART_DIR}/base --namespace ${AM_NAMESPACE}
  ${HELM} install istiod ${AM_HELM_CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
  ${HELM} install istio-ingress ${AM_HELM_CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
  ${HELM} install istio-egress ${AM_HELM_CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
  sleep 10 && patch_service_ingress
  ${ISTIOCTL} x create-remote-secret --name=${AM_CLUSTER_NAME} > ${AM_MULTISECRET}
  ${KUBECTL} apply -f ${AM_MULTISECRET_REMOTE}
  ${KUBECTL} wait --timeout=5m --for=condition=Ready pods --all -n ${AM_NAMESPACE}
  exit 0
fi

if [[ $1 = "update" ]]; then
  ${HELM} upgrade istio-base ${AM_HELM_CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
  ${HELM} upgrade istiod ${AM_HELM_CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES} || true
  ${HELM} upgrade istio-ingress ${AM_HELM_CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES} || true
  ${HELM} upgrade istio-egress ${AM_HELM_CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES} || true
  sleep 10 && patch_service_ingress || true
  ${ISTIOCTL} x create-remote-secret --name=${AM_CLUSTER_NAME} > ${AM_MULTISECRET} || true
  ${KUBECTL} wait --timeout=5m --for=condition=Ready pods --all -n ${AM_NAMESPACE}
  exit 0
fi

if [[ $1 = "install-remote-secret" ]]; then
  echo "${KUBECTL} apply -f ${AM_MULTISECRET_REMOTE}"
  ${KUBECTL} apply -f ${AM_MULTISECRET_REMOTE}|| true
  exit 0
fi

if [[ $1 = "remove" ]]; then
  ${HELM} uninstall istio-egress --namespace ${AM_NAMESPACE} || true
  ${HELM} uninstall istio-ingress --namespace ${AM_NAMESPACE} || true
  ${HELM} uninstall istiod --namespace ${AM_NAMESPACE} || true
  ${HELM} uninstall istio-base --namespace ${AM_NAMESPACE} || true
  ${KUBECTL} delete ns ${AM_NAMESPACE} || true
  exit 0
fi

if [[ $1 = "services" ]]; then
  ${KUBECTL} apply -f ${AM_SVC_DIR}
  exit 0
fi

echo "please specify action ./aspenmesh.sh install/update/install-remote-secret/remove/istioctl/services cluster1/cluster2"
exit 1
