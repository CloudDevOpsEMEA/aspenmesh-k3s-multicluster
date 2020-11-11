#!/usr/bin/env bash

echo "Upgrade apt packages"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y auto-remove
sudo apt-get -y dist-upgrade
sudo apt-get install -y grc nmap tree siege httpie tcpdump 
sudo snap install helm --classic

echo "Install k3s master"
k3s_version=v1.18.10+k3s2
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} sh -
k3s_token=$(sudo cat /var/lib/rancher/k3s/server/node-token)
k3s_url="https://k3s-1-master:6443"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_URL=${k3s_url} K3S_TOKEN=${k3s_token} sh -

echo "Install k3s node"
k3s_version=v1.18.10+k3s2
k3s_token="K106f50771675c0974e45a9abdaca7758f53b07bbbd21a4e62e5305fa6391c85a58::server:0d7843a4b75d7836d6ccdf94a809cd4b"
k3s_url="https://k3s-1-master:6443"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_URL=${k3s_url} K3S_TOKEN=${k3s_token} sh -


sudo cp /etc/rancher/k3s/k3s.yaml .kube/config
sudo chown ubuntu:ubuntu -R .kube

echo '# Kubernetes' >>~/.bashrc
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

# echo "Install Rancher persistent storage"
# kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
