# GCP Secret Manager + ESO + WIF (K3s on-prem)

## Decisao arquitetural
- Provedor de segredo: Google Secret Manager.
- Integracao no cluster: External Secrets Operator (ESO) via Argo CD.
- Autenticacao: Workload Identity Federation (WIF) sem chave JSON.
- Estrategia recomendada: `acesso direto por principal federado`.

### Por que acesso direto e a recomendacao aqui
- O ESO on-prem com `workloadIdentityFederation.serviceAccountRef` funciona de forma nativa sem `credConfig` adicional.
- Menor complexidade operacional para GitOps incremental.
- Menos pontos de erro em runtime (sem etapa extra de impersonation config dentro do store).
- Mantendo IAM por secret e por subject, o principio de minimo privilegio continua preservado.

### Quando usar impersonation
- Quando voce precisa padronizar auditoria e controle em uma SA GCP intermediaria.
- Nesse caso, alem dos bindings IAM, use `credConfig` no `workloadIdentityFederation` para declarar explicitamente a SA a ser impersonada.

## Pre-requisito critico do on-prem
Para WIF funcionar fora do GKE, o issuer OIDC do cluster precisa estar acessivel pela Google STS:
- endpoint discovery: `/.well-known/openid-configuration`
- endpoint JWKS

Sem isso, a troca de token federado falha.

## Separacao por escopo
- `shared`:
	- instalacao do ESO
	- namespace `external-secrets`
	- ServiceAccounts de autenticacao WIF (`eso-gcp-dev` e `eso-gcp-prd`)
	- ClusterSecretStores (`gcp-sm-dev` e `gcp-sm-prd`)
- `dev`:
	- ExternalSecrets de workloads dev
	- consumo por Deployments/StatefulSets em namespaces dev
- `prd`:
	- ExternalSecrets de workloads prd
	- consumo por Deployments/StatefulSets em namespaces prd

## Naming convention recomendada (GCP secrets)
- `homelab-dev-postgres-password`
- `homelab-dev-postgres-url`
- `homelab-prd-postgres-password`
- `homelab-prd-postgres-url`

## Rotacao e versionamento
- Criar nova versao do secret no Secret Manager (mesmo nome).
- ESO reconcilia por `refreshInterval`.
- Reiniciar workload somente quando a app nao recarrega credencial dinamicamente.

### Refresh manual (quando nao quiser esperar o intervalo)
1. Verificar recurso:
	- `kubectl get externalsecret postgresql-auth -n dev-apps`
2. Forcar sincronizacao:
	- `kubectl annotate externalsecret postgresql-auth -n dev-apps force-sync=$(date +%s) --overwrite`
3. Validar status:
	- `kubectl describe externalsecret postgresql-auth -n dev-apps`
	- `kubectl get secret postgresql-auth -n dev-apps -o yaml | grep resourceVersion`

## Blast radius
- Um `ClusterSecretStore` por ambiente logico (`dev`/`prd`).
- Uma identidade Kubernetes por ambiente (`eso-gcp-dev` / `eso-gcp-prd`).
- IAM no GCP por secret (lista explicita), sem papel amplo no projeto.
- Manter RBAC rigoroso para quem pode criar/editar `ExternalSecret`.

## Rollout resumido
1. Configurar issuer OIDC publico do K3s.
2. Habilitar variaveis `gcp_eso_wif_*` no Terraform de `environments/shared`.
3. Aplicar Terraform e capturar output `gcp_wif_audience`.
4. Atualizar audience dos `ClusterSecretStore` com o valor real.
5. Commitar e sincronizar Argo CD.
6. Criar/validar `ExternalSecret` nos ambientes.

## Validacao minima
- `kubectl get pods -n external-secrets`
- `kubectl get clustersecretstore`
- `kubectl describe clustersecretstore gcp-sm-dev`
- `kubectl get externalsecret -n dev-apps`
- `kubectl get secret postgresql-auth -n dev-apps -o yaml`

## Riscos e limitacoes
- Dependencia forte de OIDC issuer acessivel externamente.
- Falha de conectividade entre cluster e endpoints Google impede reconciliacao.
- Erros de IAM por secret ausente ou binding incompleto aparecem como falha no ExternalSecret.
- Em cluster single-node, indisponibilidade do node impacta todo o fluxo de reconciliacao.

## Status atual (2026-04-10)
### Concluido
- Terraform `shared` aplicado com sucesso para criar WIF Pool/Provider.
- Outputs confirmados:
	- `gcp_wif_audience = //iam.googleapis.com/projects/702302784311/locations/global/workloadIdentityPools/homelab-k3s-pool/providers/homelab-k3s-provider`
	- `gcp_wif_pool_id = homelab-k3s-pool`
	- `gcp_wif_provider_id = homelab-k3s-provider`
- ESO instalado via Argo CD e recursos de `shared-secrets-config` presentes (`ServiceAccounts` e `ClusterSecretStore`).

### Pendente bloqueante
- `ClusterSecretStore` ainda nao esta `Ready`.
- Erro mais recente observado no evento do store:
	- `invalid_grant: Error connecting to the given credential's issuer`
- Implicacao: `ExternalSecret postgresql-auth` em `dev-apps` segue com `SecretSyncedError` e o `Secret postgresql-auth` nao foi materializado.

### Pendente de autorizacao no Secret Manager
- Ainda e necessario confirmar (ou aplicar) IAM por secret para os principals federados:
	- `principal://iam.googleapis.com/projects/702302784311/locations/global/workloadIdentityPools/homelab-k3s-pool/subject/system:serviceaccount:external-secrets:eso-gcp-dev`
	- `principal://iam.googleapis.com/projects/702302784311/locations/global/workloadIdentityPools/homelab-k3s-pool/subject/system:serviceaccount:external-secrets:eso-gcp-prd`
- Papel necessario por secret: `roles/secretmanager.secretAccessor`.

## Checklist de retomada
1. Publicar issuer OIDC em dominio publico com TLS valido.
2. Validar externamente:
	 - `https://<issuer>/.well-known/openid-configuration`
	 - `https://<issuer>/openid/v1/jwks`
3. Atualizar `kubernetes_oidc_issuer_uri` no Terraform `shared` e aplicar.
4. Garantir IAM de `secretAccessor` para os dois principals federados em todos os secrets exigidos.
5. Forcar reconcile:
	 - `kubectl annotate clustersecretstore gcp-sm-dev force-sync=$(date +%s) --overwrite`
	 - `kubectl annotate externalsecret postgresql-auth -n dev-apps force-sync=$(date +%s) --overwrite`
6. Validar fim a fim:
	 - `kubectl get clustersecretstore gcp-sm-dev`
	 - `kubectl get externalsecret postgresql-auth -n dev-apps`
	 - `kubectl get secret postgresql-auth -n dev-apps`
