# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


install-cluster1: ## Install sample app in cluster1 
	kubectl apply -f 00-namespace.yaml || true
	kubectl apply -f cluster1

install-cluster2: ## Install sample app in cluster2 
	kubectl apply -f 00-namespace.yaml || true
	kubectl apply -f cluster2

test-traffic: ## Test traffic from local to remote cluster
	while true ; do kubectl exec -n sample -c sleep "`kubectl get pod -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}'`" -- curl -sS helloworld.sample:5000/hello ; done

check-endpoints: ## Check envoy sidecar endpoints
	istioctl proxy-config endpoint `kubectl get pod -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}'`.sample | grep hello

info: ## Get deployment info of this workload
	kubectl -n sample get all

restart: ## Restart all pods in this sample namespace
	kubectl -n sample rollout restart deployments
	kubectl wait --timeout=2m --for=condition=Ready pods --all -n sample

