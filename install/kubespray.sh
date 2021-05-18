#!/usr/bin/env bash

ROOT_DIR=$(pwd)
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster

source ${REPO_DIR}/environment.sh
KUBESPRAY_DIR=${REPO_DIR}/kubespray/${KUBESPRAY_VERSION}

if [[ $2 = "cluster1" ]]; then
  KUBESPRAY_CLUSTER_NAME=${KUBESPRAY_CLUSTER1_NAME}
  KUBESPRAY_INVENTORY=${REPO_DIR}/install/kubespray/${KUBESPRAY_CLUSTER1_NAME}/hosts.yaml
  KUBECTL_ALIAS=k1
  K8S_NODES=( k8s-1-master k8s-1-node1 k8s-1-node2 k8s-1-node3 k8s-1-node4 )
elif [[ $2 = "cluster2" ]]; then
  KUBESPRAY_CLUSTER_NAME=${KUBESPRAY_CLUSTER2_NAME}
  KUBESPRAY_INVENTORY=${REPO_DIR}/install/kubespray/${KUBESPRAY_CLUSTER2_NAME}/hosts.yaml
  KUBECTL_ALIAS=k2
  K8S_NODES=( k8s-2-master k8s-2-node1 k8s-2-node2 k8s-2-node3 k8s-2-node4 )
else
  echo "please specify action ./kubespray.sh create/reset/info/k9s cluster1/cluster2"
  exit 1
fi

function do_k8s_nodes {
  for node in "${K8S_NODES[@]}"
  do
    echo ${node} "${1} > /dev/null"
    ssh ${node} "${1} > /dev/null"
  done
}

KUBECONFIG_ARTIFACT=${REPO_DIR}/install/kubespray/${KUBESPRAY_CLUSTER_NAME}/artifacts/admin.conf
KUBECONFIG=${REPO_DIR}/install/kubespray/${KUBESPRAY_CLUSTER_NAME}-kubeconfig.yaml

if [[ $1 = "create" ]]; then
	cd ${KUBESPRAY_DIR}
	sudo pip3 install -r requirements.txt
	ansible-playbook -i ${KUBESPRAY_INVENTORY} --become --become-user=root cluster.yml
  cp ${KUBECONFIG_ARTIFACT} ${KUBECONFIG}
  exit 0
fi

if [[ $1 = "reset" ]]; then
	cd ${KUBESPRAY_DIR}
	sudo pip3 install -r requirements.txt
	ansible-playbook -i ${KUBESPRAY_INVENTORY} --become --become-user=root reset.yml
  cp ${KUBECONFIG_ARTIFACT} ${KUBECONFIG}
  exit 0
fi

if [[ $1 = "kubeconfig" ]]; then
  cp ${KUBECONFIG_ARTIFACT} ${KUBECONFIG}
  for k8s_node in "${K8S_NODES[@]}"
  do
    scp ${KUBECONFIG} ${k8s_node}:${HOME_DIR}/.kube/config
  done
  exit 0
fi

if [[ $1 = "kubectl" ]]; then
  do_k8s_nodes "cd /tmp ; curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl ; sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
  exit 0
fi

if [[ $1 = "k9s" ]]; then
  do_k8s_nodes "cd /tmp ; curl -LO https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz ; tar xvfz k9s_Linux_x86_64.tar.gz ; sudo mv k9s /usr/local/bin ; rm k9s_Linux_x86_64.tar.gz"
  exit 0
fi


echo "please specify action ./kubespray.sh create/reset/kubeconfig/kubectl/k9s cluster1/cluster2"
exit 1
