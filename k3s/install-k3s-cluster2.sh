#!/usr/bin/env bash

echo "Upgrade apt packages"
sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y auto-remove ; sudo apt-get -y dist-upgrade ; sudo apt-get install -y grc nmap tree siege httpie tcpdump  ; sudo snap install helm --classic

echo "Install k3s master"
k3s_version=v1.18.10+k3s2
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} sh -
k3s_token=$(sudo cat /var/lib/rancher/k3s/server/node-token)
k3s_url="https://k3s-2-master:6443"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_URL=${k3s_url} K3S_TOKEN=${k3s_token} sh -

echo "Install k3s node"
k3s_version=v1.18.10+k3s2
k3s_token="K1092b005d190c82f3aa2a26514766603bb09575ab4389088b2a56a5c2d5f1434eb::server:c64aaa1cd92d331cbf5bfde70ffd1ec7"
k3s_url="https://k3s-2-master:6443"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_URL=${k3s_url} K3S_TOKEN=${k3s_token} sh -

mkdir .kube
sudo cp /etc/rancher/k3s/k3s.yaml .kube/config
sudo chown ubuntu:ubuntu -R .kube

echo '' >>~/.bashrc
echo '# Kubernetes' >>~/.bashrc
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

# echo "Install Rancher persistent storage"
# kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
