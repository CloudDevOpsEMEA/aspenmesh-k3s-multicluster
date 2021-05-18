#!/usr/bin/env bash

ROOT_DIR=$(pwd)

GIT_REPO=https://github.com/CloudDevOpsEMEA/udf-aspenmesh-k8s

HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/udf-aspenmesh-k8s

NODES=( jumphost k8s-1-master k8s-1-node1 k8s-1-node2 k8s-1-node3 k8s-1-node4 k8s-2-master k8s-2-node1 k8s-2-node2 k8s-2-node3 k8s-2-node4 )
K8S_NODES=( k8s-1-master k8s-1-node1 k8s-1-node2 k8s-1-node3 k8s-1-node4 k8s-2-master k8s-2-node1 k8s-2-node2 k8s-2-node3 k8s-2-node4 )
K8S_NODES_CLUSTER_1=( k8s-1-master k8s-1-node1 k8s-1-node2 k8s-1-node3 k8s-1-node4 )
K8S_NODES_CLUSTER_2=( k8s-2-master k8s-2-node1 k8s-2-node2 k8s-2-node3 k8s-2-node4 )


function do_nodes {
  for node in "${NODES[@]}"
  do
    echo ${node} "${1} > /dev/null"
    ssh ${node} "${1} > /dev/null"
  done
}

function do_k8s_nodes {
  for k8s_node in "${K8S_NODES[@]}"
  do
    echo ssh ${k8s_node} "${1}"
    ssh ${k8s_node} "${1}"
  done
}

function do_k8s_nodes_cluster1 {
  for k8s_node in "${K8S_NODES_CLUSTER_1[@]}"
  do
    echo ssh ${k8s_node} "${1}"
    ssh ${k8s_node} "${1}"
  done
}

function do_k8s_nodes_cluster2 {
  for k8s_node in "${K8S_NODES_CLUSTER_2[@]}"
  do
    echo ssh ${k8s_node} "${1}"
    ssh ${k8s_node} "${1}"
  done
}


if [[ $1 = "apt_install" ]]; then
  do_nodes "sudo apt-get -y install make ansible python-jinja2 python-netaddr python3-pip systemd grc nmap tree siege"
  exit 0
fi

if [[ $1 = "apt_fix" ]]; then
  do_k8s_nodes "sudo apt-get -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-bionic docker-ce=5:19.03.14~3-0~ubuntu-bionic --allow-downgrades --allow-change-held-packages"
  exit 0
fi

if [[ $1 = "apt_update" ]]; then
  do_nodes "sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y dist-upgrade ; sudo apt-get -y autoremove"
  exit 0
fi

if [[ $1 = "git_clone" ]]; then
  do_k8s_nodes "cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null"
  exit 0
fi

if [[ $1 = "git_pull" ]]; then
  do_nodes "cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb"
  exit 0
fi

if [[ $1 = "reboot_k8s" ]]; then
  do_k8s_nodes "sudo reboot"
  exit 0
fi

if [[ $1 = "reboot_k8s_cluster1" ]]; then
  do_k8s_nodes_cluster1 "sudo reboot"
  exit 0
fi

if [[ $1 = "reboot_k8s_cluster1" ]]; then
  do_k8s_nodes_cluster2 "sudo reboot"
  exit 0
fi

if [[ $1 = "enable_multinic" ]]; then
  ssh jumphost "sudo apt-get -y install net-tools ; sudo ${REPO_DIR}/install/common/network-3nic.sh"
  sleep 5
  do_k8s_nodes "sudo apt-get -y install net-tools ; sudo ${REPO_DIR}/install/common/network-2nic.sh"
  exit 0
fi

if [[ $1 = "enable_multirouting" ]]; then
	ssh jumphost "sudo iptables -A FORWARD -i lo -j ACCEPT ; sudo iptables -A FORWARD -i ens6 -j ACCEPT ; sudo iptables -A FORWARD -i ens7 -j ACCEPT"
	ssh jumphost "sudo iptables -t nat -A POSTROUTING -o ens6 -j MASQUERADE ; sudo iptables -t nat -A POSTROUTING -o ens7 -j MASQUERADE"
	ssh jumphost "sudo iptables-save"
  sleep 5
  do_k8s_nodes_cluster1 "sudo ip route add 10.1.20.0/24 via 10.1.10.4 ; sudo iptables-save"
  do_k8s_nodes_cluster2 "sudo ip route add 10.1.10.0/24 via 10.1.20.4 ; sudo iptables-save"
  exit 0
fi

echo "please specify action ./nodes.sh apt_install/apt_fix/apt_update/git_clone/git_pull/reboot_k8s/reboot_k8s_cluster1/reboot_k8s_cluster2/enable_multinic"
exit 1
