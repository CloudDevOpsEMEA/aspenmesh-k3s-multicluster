#!/usr/bin/env bash

echo "Upgrade apt packages"
sudo apt-get -y update
sudo apt-get -y upgrade

echo "Install k3s master"
k3s_version=v1.18.10+k3s2

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} sh -
k3s_token=$(sudo cat /var/lib/rancher/k3s/server/node-token)
k3s_url="https://cluster1:6443"

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_URL=${k3s_url} K3S_TOKEN=${k3s_token} sh -

sudo cp /etc/rancher/k3s/k3s.yaml .kube/config
sudo chown ubuntu:ubuntu -R .kube

echo '# Kubernetes' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

echo "Install Rancher persistent storage"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
