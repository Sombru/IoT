#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x "$SCRIPT_DIR"/*.sh

"$SCRIPT_DIR/install_base.sh"
"$SCRIPT_DIR/install_docker.sh"
"$SCRIPT_DIR/install_kubectl.sh"
"$SCRIPT_DIR/install_k3d.sh"
"$SCRIPT_DIR/install_k3s.sh"
"$SCRIPT_DIR/install_helm.sh"
"$SCRIPT_DIR/install_argocd.sh"

echo
echo "===================================="
echo "Everything has been installed!"
echo "===================================="
echo
echo "Installed:"
echo "  ✔ Base packages"
echo "  ✔ OpenSSH"
echo "  ✔ Docker"
echo "  ✔ kubectl"
echo "  ✔ k3d"
echo "  ✔ Helm"
echo "  ✔ ArgoCD CLI"
echo
echo "Please log out and log back in so your"
echo "Docker group membership is applied."