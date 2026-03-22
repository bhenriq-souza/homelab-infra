#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

apply_env() {
  local env_dir="$1"
  echo "==> Applying ${env_dir}"
  terraform -chdir="${ROOT_DIR}/environments/${env_dir}" init
  terraform -chdir="${ROOT_DIR}/environments/${env_dir}" plan
  terraform -chdir="${ROOT_DIR}/environments/${env_dir}" apply
}

apply_env "shared"
apply_env "dev"
apply_env "prd"
