#!/usr/bin/env bash

echo "Install AspenMesh"
kubectl create ns istio-system
helm install istio-base manifests/charts/base --namespace istio-system

helm install istiod manifests/charts/istio-control/istio-discovery --namespace istio-system --values ../k3s/udf-values-cluster2.yaml
helm install istio-ingress manifests/charts/gateways/istio-ingress --namespace istio-system --values ../k3s/udf-values-cluster2.yaml
helm install istio-egress manifests/charts/gateways/istio-egress --namespace istio-system --values ../k3s/udf-values-cluster2.yaml
helm install istio-telemetry manifests/charts/istio-telemetry/grafana --namespace istio-system --values ../k3s/udf-values-cluster2.yaml

# kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# helm uninstall istiod -n istio-system
# helm uninstall istio-ingress -n istio-system
# helm uninstall istio-egress -n istio-system
# k delete ns istio-system

# helm install istiod manifests/charts/istio-control/istio-discovery --namespace istio-system --values ../k3s/udf-values-cluster2.yaml
