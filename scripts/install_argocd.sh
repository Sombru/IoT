#!/usr/bin/env bash
set -euo pipefail

echo "Installing ArgoCD CLI..."

curl -sSL \
    -o argocd \
    https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

install -m 0755 argocd /usr/local/bin/argocd

rm argocd

echo "ArgoCD CLI installed."