#!/usr/bin/env bash

echo "Git:"
git --version

echo
echo "Docker:"
docker --version

echo
echo "kubectl:"
kubectl version --client

echo
echo "k3d:"
k3d version

echo
echo "Helm:"
helm version

echo
echo "ArgoCD:"
argocd version --client

echo
echo "SSH:"
ssh -V