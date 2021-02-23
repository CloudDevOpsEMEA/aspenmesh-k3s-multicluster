# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

coredns-cluster1: ## Update coredns configmap for cluster1
	kubectl apply -f ./coredns-cluster1.yaml

istiocoredns-cluster1: ## Update coredns configmap for cluster1
	./update-dns.sh cluster1.local aspendemo.org

coredns-cluster2: ## Update coredns configmap for cluster2
	kubectl apply -f ./coredns-cluster2.yaml

istiocoredns-cluster2: ## Update coredns configmap for cluster2
	./update-dns.sh cluster2.local aspendemo.org


cluster1: istiocoredns-cluster1 coredns-cluster1 ## Update coredns and istiocoredns configmaps for cluster1

cluster2: istiocoredns-cluster2 coredns-cluster2 ## Update coredns and istiocoredns configmaps for cluster2
