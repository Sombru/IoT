#!/usr/bin/env bash
set -euo pipefail

echo "Installing nerdctl..."

wget https://github.com/containerd/nerdctl/releases/download/v2.3.5/nerdctl-2.3.5-linux-amd64.tar.gz

tar Cxzvvf /usr/bin nerdctl-2.3.5-linux-amd64.tar.gz 
rm -rf https://github.com/containerd/nerdctl/releases/download/v2.3.5/nerdctl-2.3.5-linux-amd64.tar.gz

echo "nerdctl installed."
