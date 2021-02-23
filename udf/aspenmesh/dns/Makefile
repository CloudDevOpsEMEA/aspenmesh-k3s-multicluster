# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


cluster1: ## Update coredns and istiocoredns configmaps for cluster1
	kubectl apply -f ./00-coredns-configmap-cluster1.yaml
	kubectl apply -f ./01-istiocoredns-configmap.yaml
	kubectl delete -n kube-system $(kubectl get pods -n kube-system --selector=k8s-app=kube-dns -o=name)
	kubectl delete -n istio-system $(kubectl get pods -n istio-system --selector=app=istiocoredns -o=name)


cluster2: ## Update coredns and istiocoredns configmaps for cluster2
	kubectl apply -f ./00-coredns-configmap-cluster2.yaml
	kubectl apply -f ./01-istiocoredns-configmap.yaml
	kubectl delete -n kube-system $(kubectl get pods -n kube-system --selector=k8s-app=kube-dns -o=name)
	kubectl delete -n istio-system $(kubectl get pods -n istio-system --selector=app=istiocoredns -o=name)
