#!/usr/bin/env bash

ROOT_DIR=$(pwd)
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster
DNS_CONF_DIR=${REPO_DIR}/install/dns

NODES=( jumphost k8s-1-master k8s-1-node1 k8s-1-node2 k8s-1-node3 k8s-1-node4 k8s-2-master k8s-2-node1 k8s-2-node2 k8s-2-node3 k8s-2-node4 )

function do_nodes {
  for node in "${NODES[@]}"
  do
    echo ${node} "${1} > /dev/null"
    ssh ${node} "${1} > /dev/null"
  done
}

if [[ $1 = "dnsmasq" ]]; then
  ssh jumphost "sudo apt-get install -y dnsmasq dnsutils ldnsutils"
  ssh jumphost "sudo cp ${DNS_CONF_DIR}/dnsmasq.conf /etc/dnsmasq.conf"
  ssh jumphost "sudo systemctl restart dnsmasq"
  exit 0
fi

if [[ $1 = "dnsclient" ]]; then
  do_nodes "sudo apt-get install -y dnsutils ldnsutils"
  do_nodes "sudo systemctl disable --now systemd-resolved"
  do_nodes "sudo rm -rf /etc/resolv.conf"
  do_nodes "sudo cp ${DNS_CONF_DIR}/resolv.conf /etc/resolv.conf"
  do_nodes "sudo cp ${DNS_CONF_DIR}/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf"
  exit 0
fi

if [[ $1 = "hosts" ]]; then
  ssh jumphost "cat ${DNS_CONF_DIR}/hosts | sudo tee /etc/hosts"
  ssh jumphost "sudo systemctl restart dnsmasq"
  exit 0
fi

echo "please specify action ./dns.sh dnsmasq/dnsclient/hosts"
exit 1
