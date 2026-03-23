#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

apply_env() {
  local env_dir="$1"
  local -a terraform_vars=()

  if [[ -n "${KUBECONFIG:-}" ]]; then
    terraform_vars+=("-var" "kubeconfig_path=${KUBECONFIG}")
  fi

  if [[ -n "${KUBE_CONTEXT:-}" ]]; then
    terraform_vars+=("-var" "kubeconfig_context=${KUBE_CONTEXT}")
  fi

  echo "==> Applying ${env_dir}"
  terraform -chdir="${ROOT_DIR}/environments/${env_dir}" init
  terraform -chdir="${ROOT_DIR}/environments/${env_dir}" plan "${terraform_vars[@]}"
  terraform -chdir="${ROOT_DIR}/environments/${env_dir}" apply "${terraform_vars[@]}"
}

apply_env "shared"
apply_env "dev"
apply_env "prd"
