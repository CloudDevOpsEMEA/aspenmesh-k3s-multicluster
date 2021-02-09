# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

MASTER_DNS_1 = k3s-1-master
MASTER_DNS_2 = k3s-2-master

CLUSTER_DOMAIN_1 = cluster1.local
CLUSTER_DOMAIN_2 = cluster2.local

MASTER_TOKEN_1 = K10f5d750aeedadf3fd9aa7d6c9742779da02e09cc619cd216e5fb0e951f5e1abd9::server:93c0d3cd3ba884c1edf843a7469374b9
MASTER_TOKEN_2 = K10a0f0c71dcf4db8abbaf89f835cbff4447eaffaf0f736e31f0acf6622d055a4c1::server:eec8016ff8616ddfcd53d17021baf28f


install-k3s-1-master: ## Install k3s master cluster 1
	./install-k3s-master.sh ${MASTER_DNS_1} ${CLUSTER_DOMAIN_1}
	./config-kubectl.sh

install-k3s-2-master: ## Install k3s master cluster 2
	./install-k3s-master.sh ${MASTER_DNS_2} ${CLUSTER_DOMAIN_2}
	./config-kubectl.sh

install-k3s-1-slave: ## Install k3s slave cluster 1
	./install-k3s-slave.sh ${MASTER_DNS_1} ${MASTER_TOKEN_1} ${CLUSTER_DOMAIN_1}
	./config-kubectl.sh

install-k3s-2-slave: ## Install k3s slave cluster 2
	./install-k3s-slave.sh ${MASTER_DNS_2} ${MASTER_TOKEN_2} ${CLUSTER_DOMAIN_2}
	./config-kubectl.sh

uninstall-k3s:
	./uninstall-k3s.sh