#!/usr/bin/env bash

echo "Upgrade packages"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y auto-remove
sudo apt-get -y dist-upgrade

echo "Install packages"
sudo apt-get install -y grc nmap tree siege httpie tcpdump make
sudo snap install helm --classic
sudo snap install docker
