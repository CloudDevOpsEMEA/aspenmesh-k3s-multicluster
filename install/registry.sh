#!/usr/bin/env bash

ROOT_DIR=$(pwd)

HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/aspenmesh-k8s-multicluster
DOCKER_COMPOSE_FILE=${REPO_DIR}/install/registry/docker-compose.yaml


if [[ $1 = "up" ]]; then
  echo "docker-compose up -d -f ${DOCKER_COMPOSE_FILE}"
  docker-compose -f ${DOCKER_COMPOSE_FILE} up --detach
  exit 0
fi

if [[ $1 = "restart" ]]; then
  echo "docker-compose restart -f ${DOCKER_COMPOSE_FILE}"
  docker-compose -f ${DOCKER_COMPOSE_FILE} restart
  exit 0
fi

if [[ $1 = "down" ]]; then
  echo "docker-compose down -f ${DOCKER_COMPOSE_FILE}"
  docker-compose -f ${DOCKER_COMPOSE_FILE} down
  exit 0
fi

if [[ $1 = "logs" ]]; then
  echo "---------- docker logs docker-registry-ui ----------"
  docker logs docker-registry-ui
  echo -e "\n\n---------- docker logs docker-registry ----------"
  docker logs docker-registry
  exit 0
fi

echo "please specify action ./registry.sh up/restart/down/logs"
exit 1
