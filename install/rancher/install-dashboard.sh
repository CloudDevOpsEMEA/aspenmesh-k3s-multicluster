#!/usr/bin/env bash

sudo docker run -d \
  --network=host \
  --restart=always \
  --name f5rancher \
  -v ~/dockerhost-storage/rancher:/var/lib/rancher \
  --privileged \
  rancher/rancher:latest
