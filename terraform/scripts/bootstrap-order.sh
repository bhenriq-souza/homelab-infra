#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

apply_target() {
  local target_dir="$1"
  local -a terraform_vars=()

  if [[ -n "${KUBECONFIG:-}" ]]; then
    terraform_vars+=("-var" "kubeconfig_path=${KUBECONFIG}")
  fi

  if [[ -n "${KUBE_CONTEXT:-}" ]]; then
    terraform_vars+=("-var" "kubeconfig_context=${KUBE_CONTEXT}")
  fi

  echo "==> Applying ${target_dir}"
  terraform -chdir="${ROOT_DIR}/${target_dir}" init
  terraform -chdir="${ROOT_DIR}/${target_dir}" plan "${terraform_vars[@]}"
  terraform -chdir="${ROOT_DIR}/${target_dir}" apply "${terraform_vars[@]}"
}

apply_target "clusters/homelab/bootstrap"
apply_target "clusters/homelab/dev"
apply_target "clusters/homelab/prd"
