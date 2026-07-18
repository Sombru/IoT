#!/usr/bin/env bash
set -euo pipefail

echo "Installing kubectl..."

VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)

curl -LO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"

install -m 0755 kubectl /usr/local/bin/kubectl

rm kubectl

echo "kubectl packages installed."