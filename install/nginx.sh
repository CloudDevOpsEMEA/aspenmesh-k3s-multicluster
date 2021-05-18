#!/usr/bin/env bash

ROOT_DIR=$(pwd)
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster
CERT_DIR=${REPO_DIR}/install/certs

source ${REPO_DIR}/environment.sh

if [[ $2 = "cluster1" ]]; then
  NGINX_CONF_DIR=${REPO_DIR}/install/nginx/${AM_CLUSTER1_NAME}
  MASTER_NODE=k8s-1-master
elif [[ $2 = "cluster2" ]]; then
  NGINX_CONF_DIR=${REPO_DIR}/install/nginx/${AM_CLUSTER2_NAME}
  MASTER_NODE=k8s-2-master
else
  echo "please specify action ./nginx.sh config cluster1/cluster2"
  exit 1
fi

if [[ $1 = "config" ]]; then
  ssh ${MASTER_NODE} "sudo rm -rf /etc/nginx/conf.d/*.conf ; \
    sudo cp ${NGINX_CONF_DIR}/conf.d/*.conf /etc/nginx/conf.d/ ; \
    sudo cp ${NGINX_CONF_DIR}/nginx.conf /etc/nginx/nginx.conf ; \
    sudo cp ${CERT_DIR}/wildcard/aspendemo.org-bundle.pem /etc/ssl/nginx/cert.pem ; \
    sudo cp ${CERT_DIR}/wildcard/aspendemo.org.key /etc/ssl/nginx/key.pem ; \
    sudo systemctl enable nginx.service ; \
    sudo systemctl restart nginx.service ;"
  exit 0
fi

echo "please specify action ./nginx.sh config cluster1/cluster2"
exit 1
