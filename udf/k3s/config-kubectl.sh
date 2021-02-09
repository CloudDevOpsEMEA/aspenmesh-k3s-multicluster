#!/usr/bin/env bash

echo "Make kubectl config available for user and enable auto-complete"
sudo mkdir -p ~/.kube

echo "We are configuring a master node"
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu -R ~/.kube

echo "Adding bashrc configuration"

echo '' >>~/.bashrc
echo '# Kubernetes' >>~/.bashrc
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

echo "DONE!"

