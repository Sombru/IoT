#!/bin/bash
set -euo pipefail

CLUSTER_NAME="iot-cluster"

if k3d cluster list | grep -q "^${CLUSTER_NAME}"; then
    echo ">>> Cluster '${CLUSTER_NAME}' already exists, skipping creation."
else
    echo ">>> Creating k3d cluster '${CLUSTER_NAME}'..."
    k3d cluster create "${CLUSTER_NAME}" -p "8888:8888@loadbalancer"
fi

echo ">>> Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

kubectl get nodes -o wide
echo ">>> Cluster is up."