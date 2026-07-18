#!/usr/bin/env bash
set -euo pipefail

echo "Installing base packages..."

apt update
apt upgrade -y

apt install -y \
    apt-transport-https \
    bash-completion \
    build-essential \
    ca-certificates \
    conntrack \
    curl \
    dnsutils \
    git \
    gnupg \
    htop \
    iproute2 \
    iptables \
    jq \
    lsb-release \
    nano \
    net-tools \
    openssh-client \
    openssh-server \
    software-properties-common \
    socat \
    tree \
    unzip \
    vim \
    wget \
    zip

systemctl enable ssh
systemctl start ssh

echo "Base packages installed complete."