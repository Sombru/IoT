#!/bin/bash
set -e

IP_SERVER=$1

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl

# Auto-detect the interface that owns IP_SERVER (avoids hardcoding eth1/enp0s8)
IFACE=$(ip -4 -o addr show | grep "${IP_SERVER}" | awk '{print $2}')

curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server --node-ip=${IP_SERVER} --bind-address=${IP_SERVER} \
    --advertise-address=${IP_SERVER} --flannel-iface=${IFACE} \
    --write-kubeconfig-mode=644" \
  sh -

# Wait until k3s is ready and node-token exists
until [ -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 1
done

# Expose the token to the shared /vagrant folder so the worker VM can read it
cp /var/lib/rancher/k3s/server/node-token /vagrant/token

echo "K3s server is up. Token copied to /vagrant/token"