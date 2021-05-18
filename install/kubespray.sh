#!/usr/bin/env bash

ROOT_DIR=$(pwd)
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster
KUBESPRAY_DIR=${REPO_DIR}/kubespray/${KUBESPRAY_VERSION}

source ${REPO_DIR}/environment.sh

if [[ $2 = "cluster1" ]]; then
  KUBESPRAY_CLUSTER_NAME=${KUBESPRAY_CLUSTER1_NAME}
  KUBESPRAY_INVENTORY=${HOME_DIR}/udf/kubespray/${KUBESPRAY_CLUSTER1_NAME}/hosts.yaml
  KUBECTL_ALIAS=k1
  K8S_NODES=( k8s-1-master k8s-1-node1 k8s-1-node2 k8s-1-node3 k8s-1-node4 )
elif [[ $2 = "cluster2" ]]; then
  KUBESPRAY_CLUSTER_NAME=${KUBESPRAY_CLUSTER2_NAME}
  KUBESPRAY_INVENTORY=${HOME_DIR}/udf/kubespray/${KUBESPRAY_CLUSTER2_NAME}/hosts.yaml
  KUBECTL_ALIAS=k2
  K8S_NODES=( k8s-2-master k8s-2-node1 k8s-2-node2 k8s-2-node3 k8s-2-node4 )
else
  echo "please specify action ./kubespray.sh create/reset/info/k9s cluster1/cluster2"
  exit 1
fi

KUBECONFIG=${HOME_DIR}/install/kubesrpay/${KUBESPRAY_CLUSTER_NAME}-kubeconfig.yaml

if [[ $1 = "create" ]]; then
	cd ${KUBESPRAY_DIR}
	sudo pip3 install -r requirements.txt
	ansible-playbook -i ${KUBESPRAY_INVENTORY} --become --become-user=root cluster.yml
  exit 0
fi

if [[ $1 = "reset" ]]; then
	cd ${KUBESPRAY_DIR}
	sudo pip3 install -r requirements.txt
	ansible-playbook -i ${KUBESPRAY_INVENTORY} --become --become-user=root reset.yml
  exit 0
fi

if [[ $1 = "update_kubeconfigs" ]]; then
  for k8s_node in "${K8S_NODES[@]}"
  do
    scp ${KUBECONFIG} ${k8s_node}:${HOME_DIR}/.kube/config
  done
  exit 0
fi


echo "please specify action ./kubespray.sh create/reset/info/k9s cluster1/cluster2"
exit 1
