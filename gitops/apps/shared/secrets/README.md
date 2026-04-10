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

## Intervalo atual do PostgreSQL dev
- O ExternalSecret `postgresql-auth` em `dev-apps` usa `refreshInterval: 1h`.

## Forcar refresh manual do ESO
1. Confirmar que o ExternalSecret existe:
	- `kubectl get externalsecret postgresql-auth -n dev-apps`
2. Forcar reconcile imediato via annotation:
	- `kubectl annotate externalsecret postgresql-auth -n dev-apps force-sync=$(date +%s) --overwrite`
3. Validar reconciliacao:
	- `kubectl describe externalsecret postgresql-auth -n dev-apps`
	- `kubectl get secret postgresql-auth -n dev-apps -o yaml | grep resourceVersion`
4. Confirmar que a aplicacao consumidora recebeu o novo valor (se necessario, reiniciar o pod).

## Snapshot operacional (2026-04-10)
### Estado consolidado
- WIF Pool/Provider ativos no GCP com audience esperada.
- `ClusterSecretStore` (`gcp-sm-dev`/`gcp-sm-prd`) existe no cluster, mas ainda sem `Ready=True`.
- `ExternalSecret postgresql-auth` em `dev-apps` existe com `refreshInterval: 1h`, porem ainda falha sincronizacao.
- `Secret postgresql-auth` ainda ausente em `dev-apps`.

### Erro de referencia atual
- Evento recente do store:
  - `invalid_grant: Error connecting to the given credential's issuer`

### Pendencias para concluir
1. Publicar issuer OIDC em dominio publico com TLS valido e endpoints acessiveis externamente.
2. Atualizar `kubernetes_oidc_issuer_uri` no Terraform `shared` e aplicar.
3. Garantir IAM `roles/secretmanager.secretAccessor` por secret para principals federados `eso-gcp-dev` e `eso-gcp-prd`.
4. Forcar reconcile do store e do ExternalSecret para validacao imediata.
