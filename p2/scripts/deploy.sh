#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/vagrant/project"
cd "$PROJECT_DIR"

echo "Waiting for k3s node to be ready..."
kubectl wait --for=condition=ready node --all --timeout=120s

echo "Waiting for Traefik pod to appear..."
until kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik --no-headers 2>/dev/null | grep -q .; do
    echo "Traefik pod not created yet, retrying..."
    sleep 3
done

echo "Waiting for Traefik to be ready..."
kubectl wait \
  -n kube-system \
  --for=condition=ready pod \
  -l app.kubernetes.io/name=traefik \
  --timeout=180s

echo "Deploying applications..."
kubectl apply -f confs/app1
kubectl apply -f confs/app2
kubectl apply -f confs/app3
kubectl apply -f confs/ingress.yaml

echo "Forcing pods to pick up freshly built images..."
kubectl delete pod -l app=app1 --ignore-not-found
kubectl delete pod -l app=app2 --ignore-not-found
kubectl delete pod -l app=app3 --ignore-not-found

echo "Waiting for pods to restart..."
kubectl wait --for=condition=ready pod -l app=app1 --timeout=90s
kubectl wait --for=condition=ready pod -l app=app2 --timeout=90s
kubectl wait --for=condition=ready pod -l app=app3 --timeout=90s

echo "Deployment finished"

echo ""
echo "===== Self-check ====="
for host in app1.com app2.com app3.com; do
    echo "--- ${host} ---"
    for i in 1 2 3 4 5; do
        RESPONSE=$(curl -s -H "Host: ${host}" http://192.168.56.110 || true)
        if echo "$RESPONSE" | grep -q "Hello from"; then
            echo "$RESPONSE" | grep "Hello from"
            break
        fi
        echo "Not ready yet, retrying (${i}/5)..."
        sleep 3
    done
done
echo "===== Self-check finished ====="