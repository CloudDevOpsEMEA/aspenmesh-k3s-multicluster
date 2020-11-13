# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

AM_NAMESPACE=istio-system

AM_VALUES_1=./udf/aspenmesh/udf-values-cluster1.yaml
AM_VALUES_2=./udf/aspenmesh/udf-values-cluster2.yaml
MULTICLUSTER_VALUES=./udf/aspenmesh/udf-values-multicluster-gateways.yaml

CHART_DIR=./aspenmesh-1.6.12-am2/manifests/charts
CERT_DIR=./aspenmesh-1.6.12-am2/samples/certs


install-am-1: ## Install aspen mesh in cluster 1
	kubectl create ns ${AM_NAMESPACE}
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR}/ca-cert.pem \
		--from-file=${CERT_DIR}/ca-key.pem \
		--from-file=${CERT_DIR}/root-cert.pem \
		--from-file=${CERT_DIR}/cert-chain.pem 
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}

install-am-2: ## Install aspen mesh in cluster 2
	kubectl create ns ${AM_NAMESPACE}
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=${CERT_DIR}/ca-cert.pem \
		--from-file=${CERT_DIR}/ca-key.pem \
		--from-file=${CERT_DIR}/root-cert.pem \
		--from-file=${CERT_DIR}/cert-chain.pem 
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
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
	helm upgrade istiocoredns ${CHART_DIR}/istiocoredns --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}


uninstall-am-1: ## Uninstall aspen mesh in cluster 1
	helm uninstall istio-base --namespace ${AM_NAMESPACE} || true
	helm uninstall istiod --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-ingress --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-egress --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-telemetry --namespace ${AM_NAMESPACE} || true
	kubectl delete ns ${AM_NAMESPACE} || true
	
uninstall-am-2: ## Uninstall aspen mesh in cluster 2
	helm uninstall istio-base --namespace ${AM_NAMESPACE} || true
	helm uninstall istiod --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-ingress --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-egress --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-telemetry --namespace ${AM_NAMESPACE} || true
	kubectl delete ns ${AM_NAMESPACE} || true

post-install: ## Extra installations after standard installation
	kubectl apply -f ./udf/aspenmesh/post-install
	istioctl install -f ${MULTICLUSTER_VALUES}
