# ADR-0006: CI/CD with GitHub Actions and Artifact Registry

## Status
Accepted

## Context
O homelab evoluiu ate o ponto em que aplicacoes customizadas (como `finances-control-backend` e `finances-control-frontend`) precisam de um pipeline de CI/CD para build, publicacao e deploy automatizado no cluster K3s.

Hoje todas as imagens usadas no cluster sao publicas. Nao existe Artifact Registry, workflows de GitHub Actions, nem autenticacao OIDC entre GitHub e GCP. O deploy ocorre apenas via Argo CD reconciliando manifests escritos manualmente no repositorio GitOps.

O modelo de secrets atual usa External Secrets Operator com GCP Secret Manager, e a autenticacao do ESO usa chave JSON estatica como fallback (o OIDC issuer do K3s ainda nao e acessivel publicamente).

## Decision

### Registry de imagens
- usar um unico Artifact Registry Docker no GCP chamado `homelab-apps`
- path de imagens: `us-central1-docker.pkg.dev/homelab-492918/homelab-apps/{app-name}:{tag}`
- provisionar via modulo Terraform dedicado

### Autenticacao GitHub Actions -> GCP
- usar OIDC/Workload Identity Federation, sem chave JSON estatica no GitHub
- criar pool e provider WIF dedicados para GitHub (separados do pool K3s do ESO)
- issuer: `https://token.actions.githubusercontent.com`
- service account GCP dedicada para CI (ex: `github-actions-ci`)
- attribute condition filtrando por repositorio, permitindo multiplos repos de app
- restringir push por branch: `develop` publica imagens para `dev`, `main` para `prd`

### Pull de imagens privadas no K3s
- seguir abordagem consistente com o modelo existente: SA key no GCP Secret Manager + External Secrets Operator
- criar SA no GCP com `roles/artifactregistry.reader`
- ExternalSecret cria `imagePullSecret` (tipo `kubernetes.io/dockerconfigjson`) nos namespaces `dev-apps` e `prd-apps`

### Estrutura de workflows
- reusable workflow centralizado no repositorio `homelab-gitops`
- cada app repo contem apenas um caller workflow minimo (~15 linhas)
- o reusable workflow executa: auth GCP via WIF, docker build+push, atualizacao do manifest no GitOps repo

### Atualizacao do repositorio GitOps
- o workflow de CD faz commit direto no `homelab-gitops` atualizando a tag da imagem no manifest
- o Argo CD detecta a mudanca e sincroniza automaticamente
- autenticacao para push no GitOps repo via PAT (fine-grained) com scope `contents:write` apenas no `homelab-gitops`

### Versionamento de imagens
- todo push gera tag `sha-<7 chars do commit>`
- merge em `main` ou tag Git gera tambem tag semver `vX.Y.Z`
- tag `latest` aponta para ultima imagem da branch correspondente

## Consequences

### Positivas
- elimina dependencia de imagens publicas para apps customizadas
- autenticacao sem credenciais estaticas no GitHub (WIF/OIDC)
- pipeline reutilizavel entre multiplas apps com custo minimo de onboarding
- consistencia com o modelo de secrets existente (ESO + GCP SM)
- rastreabilidade completa via Git (imagem -> commit -> deploy)
- rollback por revert de Git no repositorio GitOps

### Negativas
- o PAT para push no GitOps repo e atrelado a um usuario (mitigar futuramente com GitHub App)
- o image pull secret ainda depende de chave JSON estatica no Secret Manager (mesmo fallback do ESO)
- cada novo app repo precisa de um caller workflow, ainda que minimo

## Alternatives Considered
- Argo CD Image Updater para detectar novas tags automaticamente: descartado por adicionar componente extra e complexidade prematura
- GitHub App para autenticacao no GitOps repo: mais robusto, mas setup excessivo para o numero atual de apps
- Deploy key por repo: simples mas nao escala bem com multiplos repos
- WIF puro para image pull no K3s (sem SA key): ideal mas depende de OIDC issuer publico, que ainda nao esta disponivel
