#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFS_DIR="$SCRIPT_DIR/../confs"

kubectl apply -f "$CONFS_DIR/namespaces.yaml"

kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=Available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=Available --timeout=300s deployment/argocd-repo-server -n argocd

kubectl apply -f "$CONFS_DIR/application.yaml"

echo "admin"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""