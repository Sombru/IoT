# Inception-of-Things — Part 3: K3d and Argo CD

Login: **mmakagon**
Cluster name: **mmakagonS**
App namespace: **dev**
Argo CD namespace: **argocd**

## Overview

This part replaces Vagrant/K3s with **K3d** (K3s in Docker) and sets up a small
GitOps pipeline with **Argo CD**. Argo CD watches this repository (`p3/confs/app`)
and automatically deploys/syncs the application into the `dev` namespace whenever
the manifests change.

## Directory structure

```
p3/
├── confs/
│   ├── namespaces.yaml       # argocd + dev namespaces
│   ├── application.yaml      # Argo CD Application pointing at this repo
│   └── app/
│       ├── deployment.yaml   # wil42/playground deployment
│       └── service.yaml      # LoadBalancer service, port 8888
└── scripts/
    ├── create_cluster.sh     # creates the k3d cluster
    ├── deploy_argocd.sh      # installs Argo CD + applies Application
    └── deploy_app.sh         # quick status check of the app
```

## Prerequisites

- Docker installed and running
- k3d installed
- kubectl installed
- helm (optional, only needed for the bonus GitLab part)

## Full run from scratch

```bash
chmod +x p3/scripts/*.sh

./p3/scripts/create_cluster.sh
./p3/scripts/deploy_argocd.sh
./p3/scripts/deploy_app.sh
```

## Step-by-step commands (useful for the defense)

### 1. Cluster management (k3d)

```bash
# List existing clusters
k3d cluster list

# Create the cluster (also done by create_cluster.sh)
k3d cluster create mmakagonS --servers 1 --agents 0 -p "8888:8888@loadbalancer"

# Stop / start a cluster
k3d cluster stop mmakagonS
k3d cluster start mmakagonS

# Delete a cluster
k3d cluster delete mmakagonS

# Delete ALL k3d clusters (careful!)
k3d cluster delete --all
```

### 2. Find what's holding port 8888 (common issue)

```bash
docker ps -a --filter "publish=8888"
sudo ss -ltnp | grep 8888

# If it's an old/unrelated k3d cluster, delete it properly:
k3d cluster delete <old-cluster-name>
```

### 3. Namespaces

```bash
kubectl apply -f p3/confs/namespaces.yaml
kubectl get ns
```

### 4. Argo CD installation

```bash
# Install Argo CD manifests (server-side apply avoids the
# "annotations too long" CRD error with kubectl apply)
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for it to be ready
kubectl wait --for=condition=Available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=Available --timeout=300s deployment/argocd-repo-server -n argocd

# Check pods
kubectl get pods -n argocd
```

### 5. Argo CD admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
```

Login is `admin` with the password above.

### 6. Accessing the Argo CD UI

```bash
# Port-forward the Argo CD server to your host
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open: `https://localhost:8080`

### 7. Argo CD CLI (optional, if installed)

```bash
argocd login localhost:8080 --username admin --password <password> --insecure

argocd app list
argocd app get mmakagon-app
argocd app sync mmakagon-app
```

### 7b. Understanding sync status right after apply

```bash
kubectl get application mmakagon-app -n argocd
```

Right after `kubectl apply -f p3/confs/application.yaml`, `SYNC STATUS` may show
`Unknown` for a minute while the controller does its first refresh — this is
normal and different from `OutOfSync`. `HEALTH STATUS: Healthy` already means
the pod is running fine. If `Unknown` persists more than a couple of minutes,
force a refresh:

```bash
kubectl -n argocd annotate application mmakagon-app \
  argocd.argoproj.io/refresh=hard --overwrite

kubectl get application mmakagon-app -n argocd
```

### 8. Applying the Application manifest

```bash
kubectl apply -f p3/confs/application.yaml
kubectl get applications -n argocd
```

### 9. Checking the deployed app

```bash
kubectl get pods -n dev
kubectl get svc -n dev
kubectl describe application mmakagon-app -n argocd

curl http://localhost:8888/
# Expected: {"status":"ok", "message": "v1"}
```

### 10. Switching the app version (v1 → v2)

```bash
sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' p3/confs/app/deployment.yaml

git add p3/confs/app/deployment.yaml
git commit -m "bump playground to v2"
git push

# Argo CD auto-syncs (selfHeal + automated). To force it immediately:
kubectl patch application mmakagon-app -n argocd \
  --type merge -p '{"operation":{"sync":{}}}'

# Verify
curl http://localhost:8888/
# Expected: {"status":"ok", "message": "v2"}
```

### 11. Useful debugging commands

```bash
# Logs of Argo CD components
kubectl logs -n argocd deploy/argocd-repo-server
kubectl logs -n argocd deploy/argocd-application-controller

# Force a manual refresh/sync from CLI
kubectl -n argocd annotate application mmakagon-app \
  argocd.argoproj.io/refresh=hard --overwrite

# Delete and recreate the Application (if stuck)
kubectl delete -f p3/confs/application.yaml
kubectl apply -f p3/confs/application.yaml

# Full teardown
k3d cluster delete mmakagonS
```

## Notes

- The `application.yaml` `repoURL` must point to the public GitHub repository
  containing this project, and `targetRevision` must be a branch that actually
  exists in that remote (e.g. `main` after merging, or the working branch during
  development).
- `syncPolicy.automated` with `selfHeal: true` means any manual `kubectl edit`
  on the `dev` resources will be reverted by Argo CD back to what's in Git —
  this is expected GitOps behavior, not a bug.
- Port `8888` is exposed directly from the k3d loadbalancer to the host, so
  `curl http://localhost:8888/` works without any extra port-forwarding.
