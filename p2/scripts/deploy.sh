# #!/bin/bash
# set -e


# PROJECT_DIR="/home/vagrant/project"

# cd "$PROJECT_DIR"

# kubectl apply -f confs/app1
# kubectl apply -f confs/app2
# kubectl apply -f confs/app3
# kubectl apply -f confs/ingress.yaml

#!/bin/bash
set -e

PROJECT_DIR="/home/vagrant/project"

cd "$PROJECT_DIR"

echo "Waiting for k3s to be ready..."
kubectl wait --for=condition=ready node --all --timeout=120s

echo "Waiting for Traefik..."
kubectl wait \
  -n kube-system \
  --for=condition=ready pod \
  -l app.kubernetes.io/name=traefik \
  --timeout=120s

echo "Deploying applications..."

kubectl apply -f confs/app1
kubectl apply -f confs/app2
kubectl apply -f confs/app3
kubectl apply -f confs/ingress.yaml

echo "Deployment finished"