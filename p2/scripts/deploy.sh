#!/bin/bash
set -e


PROJECT_DIR="/home/vagrant/project"

cd "$PROJECT_DIR"

kubectl apply -f confs/app1
kubectl apply -f confs/app2
kubectl apply -f confs/app3
kubectl apply -f confs/ingress.yaml