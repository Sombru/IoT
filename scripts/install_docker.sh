#!/usr/bin/env bash
set -euo pipefail

echo "Installing Docker..."

apt update
apt install -y docker.io

systemctl enable docker
systemctl start docker

if [ -n "${SUDO_USER:-}" ]; then
    usermod -aG docker "$SUDO_USER"
fi

echo "Docker packages installed."