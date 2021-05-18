# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

AM_NAMESPACE=istio-system
AM_VERSION=1.9.1-am1
ISTIO_VERSION=1.9.1
KUBESPRAY_VERSION=release-2.15

GIT_REPO=https://github.com/CloudDevOpsEMEA/aspenmesh-k8s-multicluster
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster
KUBESPRAY_DIR=${REPO_DIR}/kubespray/${KUBESPRAY_VERSION}

AM_VALUES_1=./udf/aspenmesh/udf-values-cluster1.yaml
AM_VALUES_2=./udf/aspenmesh/udf-values-cluster2.yaml
AM_EWGW_VALUES_1=./udf/aspenmesh/udf-values-ewgw-cluster1.yaml
AM_EWGW_VALUES_2=./udf/aspenmesh/udf-values-ewgw-cluster2.yaml

ASPEN_MESH_INSTALL=./aspenmesh/aspenmesh-${AM_VERSION}
CHART_DIR=${ASPEN_MESH_INSTALL}/manifests/charts
MULTI_SECRET_DIR=./udf/aspenmesh/multi-secrets

CERT_DIR=./udf/certs
CERT_DIR_CLUSTER_1=${CERT_DIR}/cluster1
CERT_DIR_CLUSTER_2=${CERT_DIR}/cluster2


##################
### Kubernetes ###
##################

install_k8s_cluster1: ## Install k8s cluster1 using kubespray
	./install/kubespray.sh create cluster1

reset_k8s_cluster1: ## Reset k8s cluster1 using kubespray
	./install/kubespray.sh reset cluster1

install_k8s_cluster2: ## Install k8s cluster2 using kubespray
	./install/kubespray.sh create cluster2

reset_k8s_cluster2: ## Reset k8s cluster2 using kubespray
	./install/kubespray.sh reset cluster2

update_kubeconfigs: ## Update kubectl kubeconfigs
	./install/kubespray.sh update_kubeconfigs


#################
### AspenMesh ###
#################

install_am1: ## Install aspen mesh in cluster1
	./install/aspenmesh.sh install cluster1

upgrade_am1: ## Upgrade aspen mesh in cluster1
	./install/aspenmesh.sh update cluster1

remove_am1: ## Uninstall aspen mesh in cluster1
	./install/aspenmesh.sh remove cluster1

install_am2: ## Install aspen mesh in cluster2
	./install/aspenmesh.sh install cluster2

upgrade_am2: ## Upgrade aspen mesh in cluster2
	./install/aspenmesh.sh update cluster2

remove_am2: ## Uninstall aspen mesh in cluster2
	./install/aspenmesh.sh remove cluster2

install_multi_secrets: ## Install multi-cluster remote secrets in both clusters
	./install/aspenmesh.sh install-remote-secret cluster1
	./install/aspenmesh.sh install-remote-secret cluster2

post_install: ## Post installation steps
	${KUBECTL1} apply -f ./install/aspenmesh/services || true
	${KUBECTL2} apply -f ./install/aspenmesh/services || true

post_uninstall:  ## Post uninstallation steps
	${KUBECTL1} delete -f ./install/aspenmesh/services || true
	${KUBECTL2} delete -f ./install/aspenmesh/services || true

reinstall_am1: post_uninstall uninstall_am install_am1 post_install ## Reinstall aspenmesh in cluster1
reinstall_am2: post_uninstall uninstall_am install_am2 post_install ## Reinstall aspenmesh in cluster2

install_istioctl:  ## Install istioctl
	curl -sL https://istio.io/downloadIstioctl | ISTIO_VERSION=${ISTIO_VERSION} sh - && \
	sudo cp ~/.istioctl/bin/istioctl /usr/local/bin


###############
### Helpers ###
###############

hosts_apt_install: ## Install packages on all nodes
	./install/nodes.sh apt_install

hosts_apt_fix: ## Fix locked packages on all nodes
	./install/nodes.sh apt_fix

hosts_apt_update: ## Upgrade packages on all nodes
	./install/nodes.sh apt_update

hosts_git_clone: ## Clone repo on all nodes
	./install/nodes.sh git_clone

hosts_git_pull: ## Pull repo on all nodes
	./install/nodes.sh git_pull

hosts_reboot_k8s: ## Reboot all k8s nodes
	./install/nodes.sh reboot_k8s

hosts_reboot_k8s_cluster1: ## Reboot all k8s nodes from cluster1
	./install/nodes.sh reboot_k8s_cluster1

hosts_reboot_k8s_cluster2: ## Reboot all k8s nodes from cluster2
	./install/nodes.sh reboot_k8s_cluster2

hosts_enable_multinic: ## Enable multiple nics on all hosts
	./install/nodes.sh enable_multinic

hosts_enable_multirouting: ## Enable multiple network routing
	./install/nodes.sh enable_multirouting

dns_dnsmasq: ## Install and setup dnsmasq (jumphost only)
	./udf/dns.sh dnsmasq

dns_dnsclient: ## Set DNS client configuration
	./udf/dns.sh dnsclient

dns_hosts: ## Update /etc/hosts file for dnsmasq server (jumphost only)
	./udf/dns.sh hosts

restart-istiod:
	kubectl -n ${AM_NAMESPACE} rollout restart deployments/istiod
	kubectl wait --timeout=2m --for=condition=Ready pods --all -n ${AM_NAMESPACE}

restart-aspenmesh:
	kubectl -n ${AM_NAMESPACE} rollout restart deployments
	kubectl wait --timeout=5m --for=condition=Ready pods --all -n ${AM_NAMESPACE}

node-region-labels: ## Add region node labels for locality load balancing
	if [ `hostname` = "k8s-1-master" ] ; then \
		kubectl label node k8s-1-master topology.kubernetes.io/region=region1 --overwrite=true ; \
		kubectl label node k8s-1-node1 topology.kubernetes.io/region=region1 --overwrite=true ; \
		kubectl label node k8s-1-node2 topology.kubernetes.io/region=region1 --overwrite=true ; \
		kubectl label node k8s-1-node3 topology.kubernetes.io/region=region1 --overwrite=true ; \
		kubectl label node k8s-1-node4 topology.kubernetes.io/region=region1 --overwrite=true ; \
	fi
	if [ `hostname` = "k8s-2-master" ] ; then \
		kubectl label node k8s-2-master topology.kubernetes.io/region=region2 --overwrite=true ; \
		kubectl label node k8s-2-node1 topology.kubernetes.io/region=region2 --overwrite=true ; \
		kubectl label node k8s-2-node2 topology.kubernetes.io/region=region2 --overwrite=true ; \
		kubectl label node k8s-2-node3 topology.kubernetes.io/region=region2 --overwrite=true ; \
		kubectl label node k8s-2-node4 topology.kubernetes.io/region=region2 --overwrite=true ; \
	fi

node-zone-labels: ## Add zone node labels for locality load balancing
	if [ `hostname` = "k8s-1-master" ] ; then \
		kubectl label node k8s-1-master topology.kubernetes.io/zone=zone1 --overwrite=true ; \
		kubectl label node k8s-1-node1 topology.kubernetes.io/zone=zone1 --overwrite=true ; \
		kubectl label node k8s-1-node2 topology.kubernetes.io/zone=zone1 --overwrite=true ; \
		kubectl label node k8s-1-node3 topology.kubernetes.io/zone=zone2 --overwrite=true ; \
		kubectl label node k8s-1-node4 topology.kubernetes.io/zone=zone2 --overwrite=true ; \
	fi
	if [ `hostname` = "k8s-2-master" ] ; then \
		kubectl label node k8s-2-master topology.kubernetes.io/zone=zone3 --overwrite=true ; \
		kubectl label node k8s-2-node1 topology.kubernetes.io/zone=zone3 --overwrite=true ; \
		kubectl label node k8s-2-node2 topology.kubernetes.io/zone=zone3 --overwrite=true ; \
		kubectl label node k8s-2-node3 topology.kubernetes.io/zone=zone4 --overwrite=true ; \
		kubectl label node k8s-2-node4 topology.kubernetes.io/zone=zone4 --overwrite=true ; \
	fi

node-subzone-labels: ## Add subzone node labels for locality load balancing
	if [ `hostname` = "k8s-1-master" ] ; then \
		kubectl label node k8s-1-master topology.istio.io/subzone=sub1 --overwrite=true ; \
		kubectl label node k8s-1-node1 topology.istio.io/subzone=sub1 --overwrite=true ; \
		kubectl label node k8s-1-node2 topology.istio.io/subzone=sub2 --overwrite=true ; \
		kubectl label node k8s-1-node3 topology.istio.io/subzone=sub3 --overwrite=true ; \
		kubectl label node k8s-1-node4 topology.istio.io/subzone=sub4 --overwrite=true ; \
	fi
	if [ `hostname` = "k8s-2-master" ] ; then \
		kubectl label node k8s-2-master topology.istio.io/subzone=sub5 --overwrite=true ; \
		kubectl label node k8s-2-node1 topology.istio.io/subzone=sub5 --overwrite=true ; \
		kubectl label node k8s-2-node2 topology.istio.io/subzone=sub6 --overwrite=true ; \
		kubectl label node k8s-2-node3 topology.istio.io/subzone=sub7 --overwrite=true ; \
		kubectl label node k8s-2-node4 topology.istio.io/subzone=sub8 --overwrite=true ; \
	fi
