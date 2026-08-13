#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/vagrant/project"

export CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock
export CONTAINERD_NAMESPACE=k8s.io
export BUILDKIT_HOST=unix:///run/buildkit/buildkitd.sock

cd "$PROJECT_DIR"

for app in app1 app2 app3; do
    echo "Removing any old images for ${app}..."
    sudo -E nerdctl rmi -f "${app}:latest" >/dev/null 2>&1 || true
    sudo -E nerdctl rmi -f "docker.io/library/${app}:latest" >/dev/null 2>&1 || true

    echo "Copying build context for ${app} to local disk (avoiding vboxsf)..."
    rm -rf "/tmp/build-${app}"
    cp -r "confs/${app}" "/tmp/build-${app}"

    echo "Building ${app}..."
    sudo -E nerdctl build \
        --no-cache \
        -t "docker.io/library/${app}:latest" \
        "/tmp/build-${app}"
done

sudo -E nerdctl images