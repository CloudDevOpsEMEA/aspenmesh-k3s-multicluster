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
	kubectl wait --timeout=2m --for=condition=Ready pods --all -n sample

install-cluster2: ## Install sample app in cluster2 
	kubectl apply -f 00-namespace.yaml || true
	kubectl apply -f cluster2
	kubectl wait --timeout=2m --for=condition=Ready pods --all -n sample

uninstall-cluster1: ## Uninstall sample app from cluster 1
	kubectl delete -f cluster1
	kubectl delete namespace sample

uninstall-cluster2: ## Uninstall sample app from cluster 2
	kubectl delete -f cluster2
	kubectl delete namespace sample

test-traffic: ## Test traffic from local to remote cluster
	while true ; do kubectl exec -n sample -c sleep "`kubectl get pod -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}'`" -- curl -sS helloworld.sample:5000/hello ; done

check-endpoints: ## Check envoy sidecar endpoints
	istioctl proxy-config endpoint `kubectl get pod -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}'`.sample | grep hello

info: ## Get deployment info of this workload
	kubectl -n sample get all

restart: ## Restart all pods in this sample namespace
	kubectl -n sample rollout restart deployments
	kubectl wait --timeout=2m --for=condition=Ready pods --all -n sample

check-priorities: ## Check envoy sidecar priorities
	kubectl get pods -n sample -o wide -l app=helloworld -L version | grep helloworld
	kubectl exec `kubectl get pod -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}'` -c sleep -- curl -s localhost:15000/clusters | grep -E 'hello.*::priority|priority.*hello'

drain-helloworld-node1: ## Drain helloworld on node1
	kubectl exec "`kubectl get pod -n sample -l app=helloworld -l node=node1 -o jsonpath='{.items[0].metadata.name}'`" -n sample -c istio-proxy -- curl -sSL -X POST 127.0.0.1:15000/drain_listeners

drain-helloworld-node2: ## Drain helloworld on node2
	kubectl exec "`kubectl get pod -n sample -l app=helloworld -l node=node2 -o jsonpath='{.items[0].metadata.name}'`" -n sample -c istio-proxy -- curl -sSL -X POST 127.0.0.1:15000/drain_listeners

drain-helloworld-node3: ## Drain helloworld on node3
	kubectl exec "`kubectl get pod -n sample -l app=helloworld -l node=node3 -o jsonpath='{.items[0].metadata.name}'`" -n sample -c istio-proxy -- curl -sSL -X POST 127.0.0.1:15000/drain_listeners

drain-helloworld-node4: ## Drain helloworld on node4
	kubectl exec "`kubectl get pod -n sample -l app=helloworld -l node=node4 -o jsonpath='{.items[0].metadata.name}'`" -n sample -c istio-proxy -- curl -sSL -X POST 127.0.0.1:15000/drain_listeners

delete-helloworld-node1: ## Delete helloworld on node1
	kubectl delete pod "`kubectl get pod -n sample -l app=helloworld -l node=node1 -o jsonpath='{.items[0].metadata.name}'`"

delete-helloworld-node2: ## Delete helloworld on node2
	kubectl delete pod "`kubectl get pod -n sample -l app=helloworld -l node=node2 -o jsonpath='{.items[0].metadata.name}'`"

delete-helloworld-node3: ## Delete helloworld on node3
	kubectl delete pod "`kubectl get pod -n sample -l app=helloworld -l node=node3 -o jsonpath='{.items[0].metadata.name}'`"

delete-helloworld-node4: ## Delete helloworld on node4
	kubectl delete pod "`kubectl get pod -n sample -l app=helloworld -l node=node4 -o jsonpath='{.items[0].metadata.name}'`"
