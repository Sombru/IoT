#!/usr/bin/env bash
set -euo pipefail

echo "Installing nerdctl..."

BUILDKIT_VERSION=v0.24.0

sudo mkdir -p /run/buildkit

wget https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION#v}.linux-amd64.tar.gz

sudo buildkitd \
    --addr unix:///run/buildkit/buildkitd.sock \
    >/tmp/buildkit.log 2>&1 &

sudo tar -C /usr/local -xzf buildkit-${BUILDKIT_VERSION#v}.linux-amd64.tar.gz

rm buildkit-${BUILDKIT_VERSION#v}.linux-amd64.tar.gz

wget https://github.com/containerd/nerdctl/releases/download/v2.3.5/nerdctl-2.3.5-linux-amd64.tar.gz

tar Cxzvvf /usr/bin nerdctl-2.3.5-linux-amd64.tar.gz 
rm -rf nerdctl-2.3.5-linux-amd64.tar.gz

sudo -E nerdctl \
    --address /run/k3s/containerd/containerd.sock \
    --namespace k8s.io \
    # -t app1:latest \
    # /home/vagrant/project/confs/app1

echo "nerdctl installed."
