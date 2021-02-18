#!/usr/bin/env bash

ROOTCA_ORG=AspenDemo
ROOTCA_CN=aspendemo.org

echo "Generating root ca"
make root-ca ROOTCA_ORG=${ROOTCA_ORG} ROOTCA_CN=${ROOTCA_CN}

echo "Generating intermediate certs for cluster 1"
make cluster1-certs K8S_CLUSTER_DOMAIN=cluster1.local

echo "Generating intermediate certs for cluster 2"
make cluster2-certs K8S_CLUSTER_DOMAIN=cluster2.local

echo "Execute the following command to view certificate information: "
echo "openssl x509 -text -noout -in certificate.pem"