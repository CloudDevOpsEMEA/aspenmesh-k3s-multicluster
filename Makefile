# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

GIT_REPO=https://github.com/CloudDevOpsEMEA/aspenmesh-k8s-multicluster

HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster

AM_NAMESPACE=istio-system
AM_VERSION=1.9.1-am1
ISTIO_VERSION=1.9.1

AM_VALUES_1=./udf/aspenmesh/udf-values-cluster1.yaml
AM_VALUES_2=./udf/aspenmesh/udf-values-cluster2.yaml
AM_EWGW_VALUES_1=./udf/aspenmesh/udf-values-ewgw-cluster1.yaml
AM_EWGW_VALUES_2=./udf/aspenmesh/udf-values-ewgw-cluster2.yaml

ASPEN_MESH_INSTALL=./aspenmesh/aspenmesh-${AM_VERSION}
CHART_DIR=${ASPEN_MESH_INSTALL}/manifests/charts
MULTI_SECRET_DIR=./udf/aspenmesh/multi-secrets
PATCH_DIR=./udf/aspenmesh/patches

CERT_DIR=./udf/certs
CERT_DIR_CLUSTER_1=${CERT_DIR}/cluster1
CERT_DIR_CLUSTER_2=${CERT_DIR}/cluster2

KUBESPRAY_BRANCH=release-2.15
# KUBESPRAY_BRANCH=master


##################
### Kubernetes ###
##################

############################## CLUSTER1 ##############################

install-k8s-cluster1: ## Install k8s cluster1 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout ${KUBESPRAY_BRANCH} && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster1 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
	ansible-playbook -i inventory/cluster1/hosts.yaml  --become --become-user=root cluster.yml
	sudo cp /etc/kubernetes/admin.conf ~/.kube/config
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/livenessProbe/failureThreshold", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/livenessProbe/timeoutSeconds", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/failureThreshold", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/timeoutSeconds", "value":10}]'
	# kubectl patch -n kube-system deployment calico-kube-controllers --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/failureThreshold", "value":10}]'
	# kubectl patch -n kube-system deployment calico-kube-controllers --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/timeoutSeconds", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/cpu", "value":"500m"}]'

upgrade-k8s-cluster1: ## Upgrade k8s cluster1 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout ${KUBESPRAY_BRANCH} && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster1 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
	ansible-playbook -i inventory/cluster1/hosts.yaml  --become --become-user=root -e kube_version=v1.20.6 -e upgrade_cluster_setup=true cluster.yml

reset-k8s-cluster1: ## Reset k8s cluster1 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout ${KUBESPRAY_BRANCH} && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster1 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
 	ansible-playbook -i inventory/cluster1/hosts.yaml --become --become-user=root reset.yml 


############################## CLUSTER2 ##############################

install-k8s-cluster2: ## Install k8s cluster2 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout ${KUBESPRAY_BRANCH} && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster2 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
	ansible-playbook -i inventory/cluster2/hosts.yaml  --become --become-user=root cluster.yml
	sudo cp /etc/kubernetes/admin.conf ~/.kube/config
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/livenessProbe/failureThreshold", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/livenessProbe/timeoutSeconds", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/failureThreshold", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/timeoutSeconds", "value":10}]'
	# kubectl patch -n kube-system deployment calico-kube-controllers --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/failureThreshold", "value":10}]'
	# kubectl patch -n kube-system deployment calico-kube-controllers --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/timeoutSeconds", "value":10}]'
	# kubectl patch -n kube-system daemonsets calico-node --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/cpu", "value":"500m"}]'

upgrade-k8s-cluster2: ## Upgrade k8s cluster2 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout ${KUBESPRAY_BRANCH} && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster2 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
	ansible-playbook -i inventory/cluster2/hosts.yaml  --become --become-user=root -e kube_version=v1.20.6 -e upgrade_cluster_setup=true cluster.yml

reset-k8s-cluster2: ## Reset k8s cluster2 using kubespray
	cd /tmp && rm -rf /tmp/kubespray && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout ${KUBESPRAY_BRANCH} && \
	cp -R ${REPO_DIR}/udf/kubespray/cluster2 /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
 	ansible-playbook -i inventory/cluster2/hosts.yaml --become --become-user=root reset.yml 

#################
### AspenMesh ###
#################

############################## CLUSTER1 ##############################

install-am1: ## Install aspen mesh in cluster1
	kubectl create ns ${AM_NAMESPACE} || true
	kubectl label namespace ${AM_NAMESPACE} topology.istio.io/network=network1 || true
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR_CLUSTER_1}/ca-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/ca-key.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/root-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_1}/cert-chain.pem  || true
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	sleep 30
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm install istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	kubectl wait --timeout=5m --for=condition=Ready pods --all -n ${AM_NAMESPACE}

install-am1-multi: ## Enable multi-cluster in cluster1
	kubectl patch -n ${AM_NAMESPACE} service istio-ingressgateway --patch "`cat ${PATCH_DIR}/path-ingressgateway-svc-cluster1.yaml`" 

upgrade-am1: ## Upgrade aspen mesh in cluster1
	helm upgrade istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm upgrade istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true
	helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1} || true


############################## CLUSTER2 ##############################

install-am2: ## Install aspen mesh in cluster2
	kubectl create ns ${AM_NAMESPACE} || true
	kubectl label namespace ${AM_NAMESPACE} topology.istio.io/network=network2 || true
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR_CLUSTER_2}/ca-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/ca-key.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/root-cert.pem \
		--from-file=${CERT_DIR_CLUSTER_2}/cert-chain.pem  || true
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	sleep 30
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm install istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	kubectl wait --timeout=5m --for=condition=Ready pods --all -n ${AM_NAMESPACE}

install-am2-multi: ## Enable multi-cluster in cluster2
	kubectl patch -n ${AM_NAMESPACE} service istio-ingressgateway --patch "`cat ${PATCH_DIR}/path-ingressgateway-svc-cluster2.yaml`" 

upgrade-am2: ## Upgrade aspen mesh in cluster2
	helm upgrade istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE} || true
	helm upgrade istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true
	helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2} || true

uninstall-am: ## Uninstall aspen mesh in cluster
	helm uninstall istio-ewgw --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-egress --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-ingress --namespace ${AM_NAMESPACE} || true
	helm uninstall istiod --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-base --namespace ${AM_NAMESPACE} || true
	kubectl delete ns ${AM_NAMESPACE} || true

install-multi-remote-secret: ## Install multi-cluster remote secrets
	if [ hostname != "jumphost" ] ; then exit ; fi
	istioctl x create-remote-secret --context="cluster1" --name=cluster1 | kubectl apply -f - --context="cluster2"
	istioctl x create-remote-secret --context="cluster2" --name=cluster2 | kubectl apply -f - --context="cluster1"

post-install: ## Post installation steps
	kubectl apply -f ./udf/aspenmesh/services || true

post-uninstall:  ## Post uninstallation steps
	kubectl delete -f ./udf/aspenmesh/services || true

reinstall-am1: post-uninstall uninstall-am install-am1 post-install ## Reinstall aspenmesh in cluster1
reinstall-am2: post-uninstall uninstall-am install-am2 post-install ## Reinstall aspenmesh in cluster2

istioctl:  ## Install istioctl
	curl -sL https://istio.io/downloadIstioctl | ISTIO_VERSION=${ISTIO_VERSION} sh - && \
	sudo cp ~/.istioctl/bin/istioctl /usr/local/bin

###############
### Helpers ###
###############

git-clone-all: ## Clone all git repos
	ssh k8s-1-master 'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-1-node1  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-1-node2  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-1-node3  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-1-node4  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-2-master 'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-2-node1  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-2-node2  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-2-node3  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true
	ssh k8s-2-node4  'cd ${HOME_DIR} ; git clone ${GIT_REPO} > /dev/null' || true

git-pull-all: ## Pull all git repos
	ssh jumphost     'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-1-master 'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-1-node1  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-1-node2  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-1-node3  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-1-node4  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-2-master 'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-2-node1  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-2-node2  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-2-node3  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'
	ssh k8s-2-node4  'cd ${REPO_DIR}; git pull > /dev/null ; sudo updatedb'

reboot-k8s: reboot-k8s-cluster1 reboot-k8s-cluster2 ## Reboot all k8s hosts

reboot-k8s-cluster1: ## Reboot k8s cluster1 hosts
	ssh k8s-1-master sudo reboot || true
	ssh k8s-1-node1  sudo reboot || true
	ssh k8s-1-node2  sudo reboot || true
	ssh k8s-1-node3  sudo reboot || true
	ssh k8s-1-node4  sudo reboot || true

reboot-k8s-cluster2: ## Reboot k8s cluster2 hosts
	ssh k8s-2-master sudo reboot || true
	ssh k8s-2-node1  sudo reboot || true
	ssh k8s-2-node2  sudo reboot || true
	ssh k8s-2-node3  sudo reboot || true
	ssh k8s-2-node4  sudo reboot || true

upgrade-apt-packages: ## Upgrade apt packages
	ssh jumphost     'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-1-master 'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-1-node1  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-1-node2  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-1-node3  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-1-node4  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-2-master 'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-2-node1  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-2-node2  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-2-node3  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'
	ssh k8s-2-node4  'sudo apt-get -y update ; sudo apt-get -y upgrade ; sudo apt-get -y autoremove'

update-kubeconfig: ## Copy k8s kubeconfig to ~/.kube/config
	sudo cp /etc/kubernetes/admin.conf ~/.kube/config

force-apt-packages:
	ssh k8s-1-master 'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-1-node1  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-1-node2  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-1-node3  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-1-node4  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-2-master 'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-2-node1  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-2-node2  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-2-node3  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
	ssh k8s-2-node4  'sudo apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install containerd.io=1.3.9-1 docker-ce-cli=5:19.03.14~3-0~ubuntu-focal docker-ce=5:19.03.14~3-0~ubuntu-focal --allow-downgrades --allow-change-held-packages'
