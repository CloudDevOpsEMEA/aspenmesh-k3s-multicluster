# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

AM_NAMESPACE=istio-system
AM_VALUES_1=./k3s/udf-values-cluster1.yaml
AM_VALUES_2=./k3s/udf-values-cluster2.yaml


install-am-1: ## Install aspen mesh in cluster 1
	kubectl create ns ${AM_NAMESPACE}
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/ca-cert.pem \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/ca-key.pem \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/root-cert.pem \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/cert-chain.pem 
	helm install istio-base manifests/charts/base --namespace ${AM_NAMESPACE}
	helm install istiod manifests/charts/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-ingress manifests/charts/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-egress manifests/charts/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm install istio-telemetry manifests/charts/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}

install-am-2: ## Install aspen mesh in cluster 2
	kubectl create ns ${AM_NAMESPACE}
	kubectl create secret generic cacerts -n ${AM_NAMESPACE} \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/ca-cert.pem \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/ca-key.pem \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/root-cert.pem \
		--from-file=./aspenmesh-1.6.12-am2/samples/certs/cert-chain.pem 
	helm install istio-base manifests/charts/base --namespace ${AM_NAMESPACE}
	helm install istiod manifests/charts/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm install istio-ingress manifests/charts/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm install istio-egress manifests/charts/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm install istio-telemetry manifests/charts/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}


upgrade-am-1: ## Upgrade aspen mesh in cluster 1
	helm upgrade istio-base manifests/charts/base --namespace ${AM_NAMESPACE}
	helm upgrade istiod manifests/charts/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istio-ingress manifests/charts/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istio-egress manifests/charts/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}
	helm upgrade istio-telemetry manifests/charts/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_1}

upgrade-am-2: ## Upgrade aspen mesh in cluster 2
	helm upgrade istio-base manifests/charts/base --namespace ${AM_NAMESPACE}
	helm upgrade istiod manifests/charts/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-ingress manifests/charts/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-egress manifests/charts/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}
	helm upgrade istio-telemetry manifests/charts/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES_2}


uninstall-am-1: ## Uninstall aspen mesh in cluster 1
	helm uninstall istio-base --namespace ${AM_NAMESPACE}
	helm uninstall istiod --namespace ${AM_NAMESPACE}
	helm uninstall istio-ingress --namespace ${AM_NAMESPACE}
	helm uninstall istio-egress --namespace ${AM_NAMESPACE}
	helm uninstall istio-telemetry --namespace ${AM_NAMESPACE}
	kubectl delete ns ${AM_NAMESPACE}
	
uninstall-am-2: ## Uninstall aspen mesh in cluster 2
	helm uninstall istio-base --namespace ${AM_NAMESPACE}
	helm uninstall istiod --namespace ${AM_NAMESPACE}
	helm uninstall istio-ingress --namespace ${AM_NAMESPACE}
	helm uninstall istio-egress --namespace ${AM_NAMESPACE}
	helm uninstall istio-telemetry --namespace ${AM_NAMESPACE}
	kubectl delete ns ${AM_NAMESPACE}

post-install: ## Extra installations after standard installation
	kubectl apply -f ./udf/aspenmesh/post-install
