#!/usr/bin/env bash
set -euo pipefail

NERDCTL_VERSION="2.3.5"

echo "Installing nerdctl ${NERDCTL_VERSION}..."

wget -q \
  "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-full-${NERDCTL_VERSION}-linux-amd64.tar.gz"

sudo tar -C /usr/local -xzf \
    "nerdctl-full-${NERDCTL_VERSION}-linux-amd64.tar.gz"

rm "nerdctl-full-${NERDCTL_VERSION}-linux-amd64.tar.gz"

echo "Starting BuildKit..."

sudo mkdir -p /run/buildkit

sudo nohup /usr/local/bin/buildkitd \
    --addr unix:///run/buildkit/buildkitd.sock \
    >/var/log/buildkit.log 2>&1 &

until [ -S /run/buildkit/buildkitd.sock ]; do
    echo "Waiting for BuildKit..."
    sleep 1
done

echo "BuildKit is ready."

echo "nerdctl version:"
nerdctl --version

echo "buildctl version:"
buildctl --version