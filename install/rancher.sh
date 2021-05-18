#!/usr/bin/env bash


if [[ $1 = "start" ]]; then
  sudo docker run -d \
    --network=host \
    --restart=always \
    --name f5rancher \
    -v ~/dockerhost-storage/rancher:/var/lib/rancher \
    --privileged \
    rancher/rancher:latest
  exit 0
fi

if [[ $1 = "stop" ]]; then
  sudo docker stop f5rancher
  exit 0
fi

if [[ $1 = "logs" ]]; then
  sudo docker logs f5rancher
  exit 0
fi

echo "please specify action ./rancher.sh start/stop/logs"
exit 1
