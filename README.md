# Inception-of-Things (IoT) — Coursework Project

Summary
-------
This repository contains a three-part lab/project demonstrating k3s usage and
simple web applications deployed in Vagrant virtual machines. Each part is a
separate exercise with its own Vagrant configuration, scripts and Kubernetes
manifests.

Top-level layout
----------------
- `p1/` — Multi-node Vagrant cluster (server + worker). Useful for testing
  multi-node deployment and token-based join flows.
- `p2/` — Single-node k3s server VM that runs three simple web apps exposed via
  Traefik ingress (the primary coursework part: "K3s and three simple
  applications").
- `p3/` — Extra exercises: additional manifests, namespaces, a small python
  app example (`cat-app`) and ArgoCD deployment helpers.

Part summaries and where to find things
-------------------------------------

**Part 1 — Multi-node k3s (p1)**
- Location: `p1/`
- Purpose: Bring up two VMs (`anmakaroS` and `anmakaroSW`) using the
  `Vagrantfile` in `p1/`. `anmakaroS` acts as the k3s server, `anmakaroSW` as a
  worker that joins using the token produced by the server.
- Key files:
  - `p1/Vagrantfile` — defines `anmakaroS` and `anmakaroSW` and private IPs.
  - `p1/scripts/server.sh` — provisions the server (installs k3s, writes token).
  - `p1/scripts/worker.sh` — worker join script that uses the server token.
- How to run:
  ```bash
  cd IoT/p1
  vagrant up
  # check nodes from either VM:
  vagrant ssh -c "sudo kubectl get nodes"
  ```

**Part 2 — Single VM with 3 apps and Traefik (p2)**
- Location: `p2/`
- Purpose: Satisfies the coursework requirement to serve three apps on one
  IP and route by `Host` header to `app1`, `app2` (3 replicas), or default to
  `app3`.
- Key files:
  - `p2/Vagrantfile` — single VM with private IP `192.168.56.110` (host-only).
  - `p2/confs/` — contains `app1`, `app2`, `app3` manifests plus `ingress.yaml`.
  - `p2/scripts/` — `install_k3s.sh`, `install_nerdctl.sh`, `build.sh`, `deploy.sh`.
- How to run:
  ```bash
  cd IoT/p2
  vagrant up --provider=virtualbox
  # or re-run provision
  vagrant provision
  ```
  Add host entries on your laptop to access the apps by hostname:
  ```bash
  sudo -- sh -c 'echo "192.168.56.110 app1.com app2.com app3.com" >> /etc/hosts'
  # then test
  curl -H "Host: app1.com" http://192.168.56.110/
  curl -H "Host: app2.com" http://192.168.56.110/
  curl -H "Host: other.com" http://192.168.56.110/  # default -> app3
  ```

**Part 3 — Extras and ArgoCD (p3)**
- Location: `p3/`
- Purpose: Additional manifests and scripts for CI/CD or multi-app
  experimentation; includes `cat-app` (a small Python app) and helper scripts
  to deploy Argocd or other tools.
- Key files:
  - `p3/confs/` — example manifests (namespaces, apps, services).
  - `p3/scripts/create_cluster.sh` — helper for cluster setup.
  - `p3/scripts/deploy_app.sh` and `deploy_argocd.sh` — example deployment flows.

Common troubleshooting and diagnostics
-------------------------------------
- If provisioning or kubectl commands fail due to kubeconfig permissions, use
  `sudo kubectl` inside the VM: `vagrant ssh -c "sudo kubectl get pods -A"`.
- To inspect Traefik and Ingress resources:
  ```bash
  vagrant ssh -c "sudo kubectl -n kube-system get pods,svc"
  vagrant ssh -c "sudo kubectl get ingress -A -o wide"
  ```
- If apps show the wrong content, check:
  - Deployment image or `imagePullPolicy` in `p2/confs/*/deployment.yaml`.
  - Whether a `ConfigMap` is mounted into `/usr/share/nginx/html`.

Notes on images vs ConfigMaps
----------------------------
The `p2` setup can either build local images (via `nerdctl` inside the VM)
and use `imagePullPolicy: Never`, or mount static HTML with ConfigMaps into
`nginx` images. Using ConfigMaps is more reproducible for grading because it
doesn't depend on rebuilding and loading images into the VM.

Repository pointers
-------------------
- `p1/Vagrantfile`, `p1/scripts/` — multi-node example
- `p2/Vagrantfile`, `p2/confs/`, `p2/scripts/` — single-node apps + ingress
- `p3/confs/`, `p3/scripts/` — extras and ArgoCD helpers

