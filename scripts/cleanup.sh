#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

destroy_vagrant_stack() {
  local stack_dir="$1"

  if [[ -f "$stack_dir/Vagrantfile" ]]; then
    (cd "$stack_dir" && vagrant destroy -f >/dev/null 2>&1 || true)
    rm -rf "$stack_dir/.vagrant"
  fi
}

destroy_vagrant_stack "$ROOT_DIR/p1"
destroy_vagrant_stack "$ROOT_DIR/p2"

if command -v k3d >/dev/null 2>&1; then
  if k3d cluster list 2>/dev/null | awk 'NR > 1 {print $1}' | grep -qx "mmakagonS"; then
    k3d cluster delete "mmakagonS"
  fi
fi

if command -v docker >/dev/null 2>&1; then
  docker system prune -af --volumes || true
fi

if command -v vagrant >/dev/null 2>&1; then
  vagrant box list | awk '{print $1}' | sort -u | while read -r box; do
    vagrant box remove "$box" --all || true
  done
fi

rm -rf "$HOME/.kube" "$HOME/.config/argocd" "$HOME/.local/share/k3d"

echo "Cleanup finished."