#!/usr/bin/env bash
set -euo pipefail

echo "Installing k3s..."

sudo apt update -y
sudo apt install -y systemd

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

echo "k3s installed."

sudo systemctl enable k3s
sudo systemctl restart k3s

until sudo test -S /run/k3s/containerd/containerd.sock; do
    echo "Waiting for K3s containerd..."
    sleep 2
done
echo "K3s containerd is ready."

mkdir -p /home/vagrant/.kube
until [ -r /etc/rancher/k3s/k3s.yaml ]; do
    echo "Waiting for k3s.yaml to become readable..."
    sleep 1
done
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
grep -qxF 'export KUBECONFIG=/home/vagrant/.kube/config' /home/vagrant/.bashrc \
    || echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "Waiting for node to be Ready..."
until kubectl get nodes 2>/dev/null | grep -q " Ready"; do
    echo "Node not ready yet..."
    sleep 2
done
echo "Node is Ready."