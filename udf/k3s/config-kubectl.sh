#!/usr/bin/env bash

echo "Make kubectl config available for user and enable auto-complete"
sudo mkdir -p ~/.kube

if [ -f "/etc/rancher/k3s/k3s.yaml" ]; then
  echo "We are configuring a master node"
  sudo cp /etc/rancher/k3s/k3s.yaml .kube/config
else
  echo "We are configuring a slave node"
  echo "Copy the content of /etc/rancher/k3s/k3s.yaml on the master node into ~/.kube/config to enable kubectl access"
  sudo touch ~/.kube/config
fi

sudo chown ubuntu:ubuntu -R ~/.kube

echo "Adding bashrc configuration"

echo '' >>~/.bashrc
echo '# Kubernetes' >>~/.bashrc
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

echo "DONE!"

