#!/usr/bin/env bash


function printhelp {
  echo "Usage: update-dns.sh <local_dns> <global_dns>"
  echo "    <local_dns> Local cluster domain of this k8s cluster (eg cluster.local)"
  echo "    <global_dns> Global cluster domain of this k8s cluster (eg global)"
  exit 1
}

# Check if necessary input params are set
if [[ -z "${1}" || -z "${2}" ]]; then
  printhelp
else
  # Increase readability of the rest of the script
  CLUSTER_DOMAIN_LOCAL=${1}
  CLUSTER_DOMAIN_GLOBAL=${2}
fi

ISTIO_COREDNS_IP=$(kubectl get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})

echo "Generating configmaps for coredns and istiocoredns"
sed -e "s/CLUSTER_DOMAIN_LOCAL/${CLUSTER_DOMAIN_LOCAL}/g" \
    -e "s/CLUSTER_DOMAIN_GLOBAL/${CLUSTER_DOMAIN_GLOBAL}/g" \
    -e "s/ISTIO_COREDNS_IP/${ISTIO_COREDNS_IP}/g" \
    ./00-configmap.yaml > ./generated/00-configmap.yaml

echo "Appying configmaps for coredns and istiocoredns"
kubectl apply -f ./generated/00-configmap.yaml

echo "Restarting coredns and istiocoredns pods"
kubectl delete -n kube-system $(kubectl get pods -n kube-system --selector=k8s-app=kube-dns -o=name)
kubectl delete -n istio-system $(kubectl get pods -n istio-system --selector=app=istiocoredns -o=name)

echo "Done!"
