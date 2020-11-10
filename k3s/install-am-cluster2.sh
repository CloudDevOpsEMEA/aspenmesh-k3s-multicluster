#!/usr/bin/env bash

echo "Install AspenMesh"
kubectl create ns istio-system
helm install istio-base manifests/charts/base --namespace istio-system

helm install istiod manifests/charts/istio-control/istio-discovery --namespace istio-system --values udf-value.yaml

helm install istio-ingress manifests/charts/gateways/istio-ingress --namespace istio-system --values udf-value.yaml

helm install istio-egress manifests/charts/gateways/istio-egress --namespace istio-system --values udf-value.yaml
