#!/usr/bin/env bash

# Check local requirements (binaries used during the installation process)
function check_local_requirements {
  deps=( kubectl helm k9s )

  for dep in "${deps[@]}"
  do
    if ! command -v ${dep} &> /dev/null
    then
        echo "${dep} could not be found, please install this on your local system first"
        exit
    fi
  done
}

check_local_requirements

### KUBESPRAY SECTION ###

export KUBESPRAY_VERSION=release-2.15

export KUBESPRAY_CLUSTER1_NAME=cluster1
export KUBESPRAY_CLUSTER2_NAME=cluster2

### ASPEN MESH SECTION ###

export ISTIO_VERSION=1.9.1

export AM_VERSION=${ISTIO_VERSION}-am3
export AM_NAMESPACE=istio-system

export AM_CLUSTER1_NAME=cluster1
export AM_CLUSTER1_NETWORK=network1
export AM_CLUSTER1_INGRESS_IP=10.1.10.50

export AM_CLUSTER2_NAME=cluster2
export AM_CLUSTER2_NETWORK=network2
export AM_CLUSTER2_INGRESS_IP=10.1.20.50
