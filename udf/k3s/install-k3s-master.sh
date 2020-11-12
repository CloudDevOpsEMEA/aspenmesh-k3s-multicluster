#!/usr/bin/env bash

K3S_VERSION=v1.18.10+k3s2

function printhelp {
  echo "Usage: install-k3s-master.sh <master_dns>"
  echo "    <master_dns> DNS of the master (can be a /etc/hosts entry as well)"
  exit 1
}

# Check if necessary input params are set
if [[ -z "${1}" ]]; then
  printhelp
else
  # Increase readability of the rest of the script
  MASTER_DNS=${1}
fi

echo "Install k3s master"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
K3S_URL="https://${MASTER_DNS}:6443"

echo "Install kubelet and join master node"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} K3S_URL=${K3S_URL} K3S_TOKEN=${K3S_TOKEN} sh -

echo "Make kubectl config available for user and enable auto-complete"
sudo mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml .kube/config
sudo chown ubuntu:ubuntu -R ~/.kube
echo '' >>~/.bashrc
echo '# Kubernetes' >>~/.bashrc
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

