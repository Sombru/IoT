#!/bin/bash
set -e

kubectl apply -f confs/app1
kubectl apply -f confs/app2
kubectl apply -f confs/app3
kubectl apply -f confs/ingress.yaml