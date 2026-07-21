#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFS_DIR="$(cd "${SCRIPT_DIR}/../confs" && pwd)"

echo ">>> Applying namespaces..."
kubectl apply -f "${CONFS_DIR}/namespaces.yaml"

echo ">>> Installing Argo CD into namespace 'argocd'..."
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ">>> Waiting for Argo CD server to be Ready (this can take a couple of minutes)..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

echo ">>> Argo CD is up."
echo ">>> Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
echo ">>> To access the UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"