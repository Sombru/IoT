#!/usr/bin/env bash
set -euo pipefail

echo "Installing k3s..."

sudo apt install systemd -y
curl -sfL https://get.k3s.io | sh -

echo "k3s installed."

sudo systemctl enable k3s
sudo systemctl restart k3s

until sudo test -S /run/k3s/containerd/containerd.sock; do
    echo "Waiting for K3s containerd..."
    sleep 2
done

echo "K3s containerd is ready."