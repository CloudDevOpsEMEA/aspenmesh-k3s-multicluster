# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


install-nginxconf-cluster1: ## Install nginx configuration for cluster 1
	sudo rm -rf /etc/nginx/conf.d/*.conf
	sudo cp ./cluster1/0*.conf /etc/nginx/conf.d/
	sudo cp ./cluster1/nginx.conf /etc/nginx/nginx.conf
	sudo systemctl enable nginx.service
	sudo systemctl restart nginx.service

install-nginxconf-cluster2: ## Install nginx configuration for cluster 2
	sudo rm -rf /etc/nginx/conf.d/*.conf
	sudo cp ./cluster2/0*.conf /etc/nginx/conf.d/
	sudo cp ./cluster2/nginx.conf /etc/nginx/nginx.conf
	sudo systemctl enable nginx.service
	sudo systemctl restart nginx.service

install-nginxconf-jumphost: ## Install nginx configuration for jumphost
	sudo rm -rf /etc/nginx/conf.d/*.conf
	sudo cp ./jumphost/0*.conf /etc/nginx/conf.d/
	sudo cp ./jumphost/nginx.conf /etc/nginx/nginx.conf
	sudo systemctl enable nginx.service
	sudo systemctl restart nginx.service

