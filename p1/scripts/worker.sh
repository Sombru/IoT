#!/bin/bash
set -e

IP_SERVER=$1
IP_WORKER=$2

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl

# Wait for the token written by the server VM (shared /vagrant folder)
until [ -f /vagrant/token ]; do
  sleep 2
done

TOKEN=$(cat /vagrant/token)
IFACE=$(ip -4 -o addr show | grep "${IP_WORKER}" | awk '{print $2}')

curl -sfL https://get.k3s.io | \
  K3S_URL="https://${IP_SERVER}:6443" \
  K3S_TOKEN="${TOKEN}" \
  INSTALL_K3S_EXEC="agent --node-ip=${IP_WORKER} --flannel-iface=${IFACE}" \
  sh -

echo "K3s agent joined ${IP_SERVER}"