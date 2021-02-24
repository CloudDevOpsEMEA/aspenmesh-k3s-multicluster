# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

GIT_REPO=https://github.com/CloudDevOpsEMEA/aspenmesh-k3s-multicluster

HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k3s-multicluster

AM_NAMESPACE=istio-system

AM_VALUES_1=./udf/aspenmesh/udf-values-cluster1.yaml
AM_VALUES_2=./udf/aspenmesh/udf-values-cluster2.yaml

ASPEN_MESH_INSTALL=./aspenmesh/aspenmesh-1.6.14-am2
CHART_DIR=${ASPEN_MESH_INSTALL}/manifests/charts

CERT_DIR=./udf/certs
CERT_DIR_CLUSTER_1=${CERT_DIR}/cluster1
CERT_DIR_CLUSTER_2=${CERT_DIR}/cluster2


##################
### Kubernetes ###
##################

install-k8s-cluster1: ## Install k8s cluster1 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout release-2.14 && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster1 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
	ansible-playbook -i inventory/cluster1/hosts.yaml  --become --become-user=root cluster.yml

install-k8s-cluster2: ## Install k8s cluster2 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout release-2.14 && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster2 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
	ansible-playbook -i inventory/cluster2/hosts.yaml  --become --become-user=root cluster.yml


#################
### AspenMesh ###
#################

install-am-1: ## Install aspen mesh in cluster 1
	kubectl create ns ${AM_NAMESPACE} || true
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR_CLUSTER_1}/ca-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/ca-key.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/root-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/cert-chain.pem  || true
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm install istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	sleep 30
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm install istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm install istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true

install-am-2: ## Install aspen mesh in cluster 2
	kubectl create ns ${AM_NAMESPACE} || true
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR_CLUSTER_2}/ca-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/ca-key.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/root-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/cert-chain.pem  || true
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm install istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	sleep 30
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm install istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm install istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true

upgrade-am-1: ## Upgrade aspen mesh in cluster 1
	helm upgrade istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm upgrade istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm upgrade istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm upgrade istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true

upgrade-am-2: ## Upgrade aspen mesh in cluster 2
	helm upgrade istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm upgrade istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm upgrade istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm upgrade istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true

uninstall-am: ## Uninstall aspen mesh in cluster
	helm uninstall istio-telemetry --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-egress --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-ingress --namespace ${AM_NAMESPACE} || true
	helm uninstall istiocoredns --namespace ${AM_NAMESPACE} || true
	helm uninstall istiod --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-base --namespace ${AM_NAMESPACE} || true
	kubectl delete ns ${AM_NAMESPACE} || true

post-install: ## Extra installations after standard installation
	kubectl apply -f ./udf/aspenmesh/post-install


###############
### Helpers ###
###############

git-clone-all: ## Clone all git repos
	# ssh jumphost 		 	'cd ${HOME_DIR} ; git clone ${GIT_REPO}'
	ssh k3s-1-master	'cd ${HOME_DIR} ; git clone ${GIT_REPO}'
	ssh k3s-1-node1  	'cd ${HOME_DIR} ; git clone ${GIT_REPO}'
	ssh k3s-1-node2  	'cd ${HOME_DIR} ; git clone ${GIT_REPO}'
	ssh k3s-2-master 	'cd ${HOME_DIR} ; git clone ${GIT_REPO}'
	ssh k3s-2-node1  	'cd ${HOME_DIR} ; git clone ${GIT_REPO}'
	ssh k3s-2-node2  	'cd ${HOME_DIR} ; git clone ${GIT_REPO}'

git-pull-all: ## Pull all git repos
	ssh jumphost 			'cd ${REPO_DIR}; git pull ; sudo updatedb'
	ssh k3s-1-master	'cd ${REPO_DIR}; git pull ; sudo updatedb'
	ssh k3s-1-node1 	'cd ${REPO_DIR}; git pull ; sudo updatedb'
	ssh k3s-1-node2   'cd ${REPO_DIR}; git pull ; sudo updatedb'
	ssh k3s-2-master  'cd ${REPO_DIR}; git pull ; sudo updatedb'
	ssh k3s-2-node1 	'cd ${REPO_DIR}; git pull ; sudo updatedb'
	ssh k3s-2-node2   'cd ${REPO_DIR}; git pull ; sudo updatedb'

reboot-k8s: reboot-k8s-cluster1 reboot-k8s-cluster2 ## Reboot all k8s hosts

reboot-k8s-cluster1: ## Reboot k8s cluster1 hosts
	ssh k3s-1-master	sudo reboot || true
	ssh k3s-1-node1  	sudo reboot || true
	ssh k3s-1-node2  	sudo reboot || true

reboot-k8s-cluster2: ## Reboot k8s cluster2 hosts
	ssh k3s-2-master 	sudo reboot || true
	ssh k3s-2-node1  	sudo reboot || true
	ssh k3s-2-node2  	sudo reboot || true