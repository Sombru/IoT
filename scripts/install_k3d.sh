#!/usr/bin/env bash
set -euo pipefail

echo "Installing k3d..."

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "k3d installed."