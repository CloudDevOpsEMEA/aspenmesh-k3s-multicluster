# Makefile

.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: install uninstall

install:  ## Install Kiali
	helm install --namespace istio-system --set auth.strategy="anonymous" --repo https://kiali.org/helm-charts kiali-server kiali-server
	kubectl apply -f 04-kiali-nodeport-svc.yaml

uninstall:  ## Uninstall Kiali
	helm uninstall --namespace istio-system kiali-server
	kubectl delete crd monitoringdashboards.monitoring.kiali.io
	kubectl delete -f 04-kiali-nodeport-svc.yaml
