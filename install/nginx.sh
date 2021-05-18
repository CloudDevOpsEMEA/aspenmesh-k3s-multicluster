#!/usr/bin/env bash

ROOT_DIR=$(pwd)
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster
CERT_DIR=${REPO_DIR}/install/certs

source ${REPO_DIR}/environment.sh

NGINX_CONF_DIR=${REPO_DIR}/install/nginx

if [[ $2 = "cluster1" ]]; then
  NGINX_CLUSTER_CONF_DIR=${REPO_DIR}/install/nginx/${AM_CLUSTER1_NAME}
  MASTER_NODE=k8s-1-master
elif [[ $2 = "cluster2" ]]; then
  NGINX_CONF_DIR=${REPO_DIR}/install/nginx/${AM_CLUSTER2_NAME}
  MASTER_NODE=k8s-2-master
else
  echo "please specify action ./nginx.sh config cluster1/cluster2"
  exit 1
fi

if [[ $1 = "install" ]]; then
  ssh ${MASTER_NODE} " sudo mkdir -p /etc/ssl/nginx
    sudo cp ${NGINX_CONF_DIR}/nginx-repo.crt /etc/ssl/nginx/
    sudo cp ${NGINX_CONF_DIR}/nginx-repo.key /etc/ssl/nginx/
    sudo wget -P /tmp https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add /tmp/nginx_signing.key
    sudo wget -P /tmp https://cs.nginx.com/static/keys/app-protect-security-updates.key && sudo apt-key add /tmp/app-protect-security-updates.key
    sudo apt-get install -y apt-transport-https lsb-release ca-certificates
    printf \"deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n\" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
    printf \"deb https://pkgs.nginx.com/app-protect/ubuntu `lsb_release -cs` nginx-plus\n\" | sudo tee /etc/apt/sources.list.d/nginx-app-protect.list
    printf \"deb https://pkgs.nginx.com/app-protect-security-updates/ubuntu `lsb_release -cs` nginx-plus\n\" | sudo tee -a /etc/apt/sources.list.d/nginx-app-protect.list
    printf \"deb https://pkgs.nginx.com/modsecurity/ubuntu `lsb_release -cs` nginx-plus\n\" | sudo tee /etc/apt/sources.list.d/nginx-modsecurity.list
    sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
    sudo apt-get update -y
    sudo apt-get install -y nginx-plus
    sudo apt-get install -y app-protect app-protect-attack-signatures || true
    sudo apt-get install -y nginx-plus nginx-plus-module-modsecurity || true
    nginx -v"
  exit 0
fi

if [[ $1 = "config" ]]; then
  ssh ${MASTER_NODE} "sudo rm -rf /etc/nginx/conf.d/*.conf ; \
    sudo cp ${NGINX_CLUSTER_CONF_DIR}/conf.d/*.conf /etc/nginx/conf.d/ ; \
    sudo cp ${NGINX_CLUSTER_CONF_DIR}/nginx.conf /etc/nginx/nginx.conf ; \
    sudo cp ${CERT_DIR}/wildcard/aspendemo.org-bundle.pem /etc/ssl/nginx/cert.pem ; \
    sudo cp ${CERT_DIR}/wildcard/aspendemo.org.key /etc/ssl/nginx/key.pem ; \
    sudo systemctl enable nginx.service ; \
    sudo systemctl restart nginx.service ;"
  exit 0
fi

echo "please specify action ./nginx.sh config cluster1/cluster2"
exit 1
