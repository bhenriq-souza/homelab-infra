# Shared Secrets (GCP Secret Manager + ESO + Service Account Key)

Este diretorio contem o estado desejado para integracao de secrets usando chave JSON da Google Service Account, sem Workload Identity Federation.

## Objetivo
- Usar GCP Secret Manager como fonte unica de verdade.
- Usar ESO para sincronizar em Secrets nativos do Kubernetes.
- Manter segregacao por ambiente (`dev` e `prd`).
- Manter segredo sensivel fora do Git.

## Fluxo resumido
1. Armazenar a chave local em `secrets/<ambiente>/gcp-sa.json` (arquivo ignorado pelo Git).
2. Executar `scripts/apply-gcp-sa-key-secret.sh <ambiente>` para criar/atualizar o Secret no namespace `external-secrets`.
3. O `ClusterSecretStore` do ambiente autentica no GCP via `auth.secretRef`.
4. Cada `ExternalSecret` usa o `ClusterSecretStore` correspondente e sincroniza o Secret da aplicacao.

## Nomes de Secret por ambiente
- `dev`: `eso-gcp-sa-key-dev`
- `prd`: `eso-gcp-sa-key-prd`

## Validacao rapida
- `kubectl get secret -n external-secrets eso-gcp-sa-key-dev`
- `kubectl get clustersecretstore gcp-sm-dev -o yaml`
- `kubectl describe clustersecretstore gcp-sm-dev`
- `kubectl get externalsecret -n dev-apps`
- `kubectl get secret -n dev-apps postgresql-auth`

## Rotacao da chave da service account
1. Gerar nova chave no GCP para a service account do ambiente.
2. Substituir o arquivo local `secrets/<ambiente>/gcp-sa.json`.
3. Reexecutar `scripts/apply-gcp-sa-key-secret.sh <ambiente>`.
4. Confirmar `Ready=True` no `ClusterSecretStore` e reconciliar `ExternalSecret` se necessario.
