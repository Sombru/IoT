#!/usr/bin/env bash
set -euo pipefail

echo "Installing k3d..."

curl -sfL https://get.k3s.io | sh -

echo "k3d installed."