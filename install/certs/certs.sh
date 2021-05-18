#!/usr/bin/env bash

ROOT_DIR=$(pwd)

DOMAIN=aspendemo.org

if [[ $1 = "root-ca" ]]; then
  make -f ../../../aspenmesh/aspenmesh-1.9.1-am1/tools/certs/Makefile.selfsigned.mk root-ca 
	exit 0
fi

if [[ $1 = "cluster" ]]; then
  make -f ../../../aspenmesh/aspenmesh-1.9.1-am1/tools/certs/Makefile.selfsigned.mk demo-cacerts
	exit 0
fi

if [[ $1 = "wildcard" ]]; then
  mkdir -p ./wildcard
  openssl req -out ./wildcard/${DOMAIN}.csr -newkey rsa:4096 -sha512 -nodes -keyout ./wildcard/${DOMAIN}.key -subj "/CN=*.${DOMAIN}/O=Istio"
  openssl x509 -req -sha512 -days 3650 -CA ./root-cert.pem -CAkey ./root-key.pem -set_serial 0 -in ./wildcard/${DOMAIN}.csr -out ./wildcard/${DOMAIN}.pem
  cat ./wildcard/${DOMAIN}.pem ./root-cert.pem >> ./wildcard/${DOMAIN}-bundle.pem
	exit 0
fi

if [[ $1 = "client" ]]; then
  mkdir -p ./client
  openssl req -out ./client/client.${DOMAIN}.csr -newkey rsa:4096 -sha512 -nodes -keyout ./client/client.${DOMAIN}.key -subj "/CN=client.${DOMAIN}/O=Client"
  openssl x509 -req -sha512 -days 3650 -CA ./root-cert.pem -CAkey ./root-key.pem -set_serial 1 -in ./client/client.${DOMAIN}.csr -out ./client/client.${DOMAIN}.pem
	exit 0
fi

if [[ $1 = "print-root-ca" ]]; then
  openssl x509 -in ./root-cert.pem -text
	exit 0
fi

if [[ $1 = "print-cluster" ]]; then
  openssl x509 -in ./demo/ca-cert.pem -text
	exit 0
fi

if [[ $1 = "print-wildcard" ]]; then
  openssl x509 -in ./wildcard/${DOMAIN}.pem -text
  openssl x509 -in ./wildcard/${DOMAIN}-bundle.pem -text
	exit 0
fi

if [[ $1 = "print-client" ]]; then
  openssl x509 -in ./client/client.${DOMAIN}.pem -text
	exit 0
fi

echo "please specify action ./certs.sh root-ca/cluster/wildcard/client/print-root-ca/print-cluster/print-wildcard/print-client"
exit 1