#!/usr/bin/env bash

echo "Uninstalling k3s server"
/usr/local/bin/k3s-uninstall.sh

echo "Uninstalling k3s agent"
/usr/local/bin/k3s-agent-uninstall.sh
