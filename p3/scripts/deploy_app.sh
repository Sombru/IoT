#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFS_DIR="$(cd "${SCRIPT_DIR}/../confs" && pwd)"

echo ">>> Applying Argo CD Application (playground)..."
kubectl apply -f "${CONFS_DIR}/application.yaml"

echo ">>> Waiting for the app to sync into namespace 'dev'..."
sleep 5
kubectl get applications -n argocd
kubectl get pods -n dev