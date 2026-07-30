#!/bin/bash
set -e

CLUSTER_NAME="mmakagonS"

if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    k3d cluster delete "$CLUSTER_NAME"
fi

k3d cluster create "$CLUSTER_NAME" \
    --servers 1 \
    --agents 0 \
    -p "8888:8888@loadbalancer"

kubectl cluster-info
kubectl get nodes