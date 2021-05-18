#!/usr/bin/env bash


if [[ $1 = "start" ]]; then
  echo "sudo docker run -d --network=host --restart=always --name f5rancher -v ~/dockerhost-storage/rancher:/var/lib/rancher --privileged rancher/rancher:latest"
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
  echo "sudo docker stop f5rancher"
  sudo docker stop f5rancher
  echo "sudo docker rm f5rancher"
  sudo docker rm f5rancher
  exit 0
fi

if [[ $1 = "logs" ]]; then
  echo "sudo docker logs f5rancher"
  sudo docker logs f5rancher
  exit 0
fi

echo "please specify action ./rancher.sh start/stop/logs"
exit 1
