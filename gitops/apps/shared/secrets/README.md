# Shared Secrets (GCP Secret Manager + ESO + WIF)

Este diretorio contem o estado desejado para integracao de secrets sem chave JSON.

## Ordem de deploy
1. Aplicar Terraform do ambiente `shared` com `gcp_eso_wif_enabled = true`.
2. Validar outputs de WIF no Terraform.
3. Substituir `PROJECT_NUMBER` nos `ClusterSecretStore` (ou ajustar pool/provider se customizados).
4. Commitar e deixar Argo CD sincronizar `shared-secrets-operator` e `shared-secrets-config`.
5. Aplicar ExternalSecrets dos workloads (`dev`/`prd`).

## Dependencias
- K3s com issuer OIDC acessivel externamente (discovery + JWKS).
- APIs GCP habilitadas pelo Terraform.
- Secrets ja criados manualmente no Secret Manager.
- Fluxo padrao usa principal federado direto (`gcp_use_service_account_impersonation = false`).

## Validacao rapida
- `kubectl get pods -n external-secrets`
- `kubectl get clustersecretstore`
- `kubectl describe clustersecretstore gcp-sm-dev`
- `kubectl get externalsecret -n dev-apps`
- `kubectl get secret postgresql-auth -n dev-apps`

## Rotacao de secret
1. Criar nova versao no Secret Manager (mesma chave).
2. Aguardar `refreshInterval` do ExternalSecret ou forcar reconcile.
3. Confirmar novo `resourceVersion` no Secret Kubernetes.
4. Reiniciar workload consumidor se a aplicacao nao reler variaveis dinamicamente.
