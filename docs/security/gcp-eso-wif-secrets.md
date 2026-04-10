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
