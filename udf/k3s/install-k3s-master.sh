#!/usr/bin/env bash

K3S_VERSION=v1.18.15+k3s1

function printhelp {
  echo "Usage: install-k3s-master.sh <master_dns> <cluster_domain>"
  echo "    <master_dns> DNS of the master (can be a /etc/hosts entry as well)"
  echo "    <cluster_domain> Cluster Domain for this cluster (eg cluster.local)"
  exit 1
}

# Check if necessary input params are set
if [[ -z "${1}" || -z "${2}" ]]; then
  printhelp
else
  # Increase readability of the rest of the script
  MASTER_DNS=${1}
  CLUSTER_DOMAIN=${2}
fi

K3S_ARGS="--cluster-domain ${CLUSTER_DOMAIN}"

echo "Install k3s server on ${MASTER_DNS} with cluster domain ${CLUSTER_DOMAIN}"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} INSTALL_K3S_EXEC="${K3S_ARGS}" sh -
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
K3S_URL="https://${MASTER_DNS}:6443"

echo "Installation complete"
echo "K3S_TOKEN = ${K3S_TOKEN}"
echo "K3S_URL = ${K3S_URL}"



