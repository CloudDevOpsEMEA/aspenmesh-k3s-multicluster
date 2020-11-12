#!/usr/bin/env bash

K3S_VERSION=v1.18.10+k3s2

function printhelp {
  echo "Usage: install-k3s-slave.sh <master_dns> <master_token>"
  echo "    <master_dns> DNS of the master (can be a /etc/hosts entry as well)"
  echo "    <master_token> K3S master token needed to join the cluster"
  exit 1
}

# Check if necessary input params are set
if [[ -z "${1}" || -z "${2}" ]]; then
  printhelp
else
  # Increase readability of the rest of the script
  MASTER_DNS=${1}
  K3S_TOKEN=${2}
fi

K3S_URL="https://${MASTER_DNS}:6443"

echo "Install kubelet and join master node"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} K3S_URL=${K3S_URL} K3S_TOKEN=${K3S_TOKEN} sh -

echo "Make kubectl config available for user and enable auto-complete"
sudo mkdir -p ~/.kube
sudo touch ~/.kube/config
sudo chown ubuntu:ubuntu -R ~/.kube
echo '' >>~/.bashrc
echo '# Kubernetes' >>~/.bashrc
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

echo "copy the content of /etc/rancher/k3s/k3s.yaml on the master node into ~/.kube/config to enable kubectl access"