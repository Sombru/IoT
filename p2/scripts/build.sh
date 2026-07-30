#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/vagrant/project"

export CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock
export CONTAINERD_NAMESPACE=k8s.io
export BUILDKIT_HOST=unix:///run/buildkit/buildkitd.sock

cd "$PROJECT_DIR"

for app in app1 app2 app3; do
    if ! sudo -E nerdctl image inspect "${app}:latest" >/dev/null 2>&1; then
        echo "Building ${app}..."
        sudo -E nerdctl build \
            -t "${app}:latest" \
            "confs/${app}"
    fi
done

sudo -E nerdctl images