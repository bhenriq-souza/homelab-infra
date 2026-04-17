#!/usr/bin/env bash
set -euo pipefail

# Cria/atualiza o Secret com a chave JSON da GCP Service Account para o ESO.
# Uso:
#   scripts/apply-gcp-sa-key-secret.sh dev
#   scripts/apply-gcp-sa-key-secret.sh prd

ENVIRONMENT="${1:-dev}"
NAMESPACE="external-secrets"
LOCAL_FILE="secrets/${ENVIRONMENT}/gcp-sa.json"
SECRET_NAME="eso-gcp-sa-key-${ENVIRONMENT}"
SECRET_KEY="service-account.json"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "Erro: kubectl nao encontrado no PATH." >&2
  exit 1
fi

if [[ ! -f "${LOCAL_FILE}" ]]; then
  echo "Erro: arquivo de chave nao encontrado: ${LOCAL_FILE}" >&2
  echo "Crie o arquivo localmente (fora do Git) e execute novamente." >&2
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic "${SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  --from-file "${SECRET_KEY}=${LOCAL_FILE}" \
  --dry-run=client \
  -o yaml \
| kubectl apply -f -

kubectl label secret "${SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  "homelab.io/component=secrets" \
  "homelab.io/environment=${ENVIRONMENT}" \
  --overwrite >/dev/null

echo "Secret aplicado com sucesso: ${NAMESPACE}/${SECRET_NAME}"
echo "Arquivo usado: ${LOCAL_FILE}"
