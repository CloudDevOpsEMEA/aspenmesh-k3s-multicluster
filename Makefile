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

local-storage: ## Install Rancher local storage provisioning
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
	kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

install-am-1: ## Install aspen mesh in cluster 1
	kubectl create ns ${AM_NAMESPACE}
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR_CLUSTER_1}/ca-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/ca-key.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/root-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/cert-chain.pem 
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm install istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}

install-am-2: ## Install aspen mesh in cluster 2
	kubectl create ns ${AM_NAMESPACE}
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR_CLUSTER_2}/ca-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/ca-key.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/root-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/cert-chain.pem 
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm install istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm install istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm install istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}


upgrade-am-1: ## Upgrade aspen mesh in cluster 1
	helm upgrade istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm upgrade istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}

upgrade-am-2: ## Upgrade aspen mesh in cluster 2
	helm upgrade istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm upgrade istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}


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
