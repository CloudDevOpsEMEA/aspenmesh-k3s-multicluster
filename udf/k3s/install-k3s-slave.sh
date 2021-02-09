#!/usr/bin/env bash

K3S_VERSION=v1.18.15+k3s1

function printhelp {
  echo "Usage: install-k3s-slave.sh <master_dns> <master_token> <cluster_domain>"
  echo "    <master_dns> DNS of the master (can be a /etc/hosts entry as well)"
  echo "    <master_token> K3S master token needed to join the cluster"
  echo "    <cluster_domain> Cluster Domain for this cluster (eg cluster.local)"
  exit 1
}

# Check if necessary input params are set
if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then
  printhelp
else
  # Increase readability of the rest of the script
  MASTER_DNS=${1}
  K3S_TOKEN=${2}
  CLUSTER_DOMAIN=${3}
fi

K3S_URL="https://${MASTER_DNS}:6443"
K3S_ARGS="--kubelet-arg=\"cluster-domain=${CLUSTER_DOMAIN}\""

echo "Install k3s agent with cluster domain ${CLUSTER_DOMAIN}"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} K3S_URL=${K3S_URL} K3S_TOKEN=${K3S_TOKEN} INSTALL_K3S_EXEC=${K3S_ARGS} sh -
