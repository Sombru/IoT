#!/bin/bash
set -e

kubectl get pods -n dev
kubectl get svc -n dev

curl -s http://localhost:8888/ || echo "no response yet"