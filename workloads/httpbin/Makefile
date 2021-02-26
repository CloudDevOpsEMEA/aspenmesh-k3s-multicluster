# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


deploy: ## Deploy httpbin
	kubectl apply -f 00-namespace.yaml && sleep 5
	kubectl apply -f 01-httpbin.yaml
	kubectl apply -f 02-ingress.yaml

undeploy: ## Undeploy httpbin
	kubectl delete -f 02-ingress.yaml
	kubectl delete -f 01-httpbin.yaml
	kubectl delete -f 00-namespace.yaml

run-load-200:  ## Run 200 OK workload test
	k6 run ./load-scripts/200-OK.js

run-load-500:  ## Run 500 Internal Server Error workload test
	k6 run ./load-scripts/500-InternalServerError.js
