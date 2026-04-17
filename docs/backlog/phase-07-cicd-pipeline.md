# Phase 07 - CI/CD Pipeline

## Objetivo
Estabelecer o pipeline de CI/CD completo para aplicacoes customizadas do homelab, desde o build de imagens ate o deploy automatizado no cluster K3s via Argo CD.

## ADR de referencia
`docs/adr/ADR-0006-cicd-with-github-actions-and-artifact-registry.md`

## Decisoes consolidadas

### Artifact Registry
- registry unico `homelab-apps` no GCP (`us-central1`)
- path: `us-central1-docker.pkg.dev/homelab-492918/homelab-apps/{app-name}:{tag}`
- provisionado via modulo Terraform

### Autenticacao GitHub -> GCP
- OIDC/WIF sem chave JSON estatica no GitHub
- pool e provider WIF dedicados para GitHub (separados do pool K3s)
- SA dedicada `github-actions-ci` com `roles/artifactregistry.writer`
- restricao por branch: `develop` -> dev, `main` -> prd

### Image Pull Secret no K3s
- SA com `roles/artifactregistry.reader`
- key JSON armazenada no GCP Secret Manager
- ExternalSecret cria `imagePullSecret` em `dev-apps` e `prd-apps`

### Workflows
- reusable workflow centralizado em `homelab-gitops/.github/workflows/`
- caller workflow minimo em cada app repo
- PAT fine-grained para push no repo GitOps (scope: `contents:write` no `homelab-gitops`)

### Versionamento
- `sha-<7 chars>` em todo push
- `vX.Y.Z` em merge na main ou tag Git
- `latest` aponta para ultima imagem da branch correspondente

### Atualizacao do GitOps
- workflow faz commit direto no `homelab-gitops` alterando a tag da imagem
- Argo CD detecta e sincroniza automaticamente

## Macrotarefas (ordem de implementacao)

### 1. Artifact Registry (Terraform)
- [ ] criar modulo `terraform/modules/artifact-registry`
- [ ] aplicar no entrypoint do cluster homelab
- [ ] validar acesso ao registry via gcloud

### 2. GitHub OIDC -> GCP WIF (Terraform)
- [ ] criar modulo `terraform/modules/gcp-github-wif`
- [ ] provisionar pool, provider e SA `github-actions-ci`
- [ ] configurar attribute mapping (repository, repository_owner, ref)
- [ ] binding IAM para `roles/artifactregistry.writer`
- [ ] suportar multiplos repos de app via variavel de lista

### 3. Image Pull Secret (Terraform + GitOps)
- [ ] criar SA com `roles/artifactregistry.reader`
- [ ] exportar key JSON para o GCP Secret Manager
- [ ] criar ExternalSecret para `imagePullSecret` em `dev-apps`
- [ ] criar ExternalSecret para `imagePullSecret` em `prd-apps`
- [ ] validar pull de imagem privada no cluster

### 4. Reusable Workflow (homelab-gitops)
- [ ] criar `homelab-gitops/.github/workflows/docker-build-push.yaml`
- [ ] implementar steps: auth GCP, docker build, push AR, update manifest, commit
- [ ] configurar PAT fine-grained como secret de organizacao ou repo
- [ ] documentar inputs esperados do caller workflow

### 5. Caller Workflow (app repo)
- [ ] criar workflow caller no primeiro app repo (ex: `finances-control-backend`)
- [ ] mapear branch -> environment (develop=dev, main=prd)
- [ ] validar fluxo end-to-end: push -> build -> push image -> update gitops -> argocd sync

### 6. Validacao end-to-end
- [ ] push em develop -> imagem no AR com tag sha -> manifest atualizado em dev -> deploy no K3s
- [ ] push em main -> imagem no AR com tag sha+semver -> manifest atualizado em prd -> deploy no K3s
- [ ] rollback via revert de commit no homelab-gitops

## Criterios de aceite
- imagem privada buildada e publicada no Artifact Registry sem credencial estatica no GitHub
- cluster K3s faz pull de imagem privada via imagePullSecret gerenciado pelo ESO
- deploy automatizado via Argo CD apos atualizacao do manifest no GitOps repo
- rollback funcional por revert de Git
- pipeline reutilizavel entre multiplos app repos
- segregacao dev/prd por branch

## Dependencias
- GCP project `homelab-492918` ativo
- Argo CD operacional no cluster homelab
- External Secrets Operator funcional (mesmo com fallback de SA key)
- repositorios de app criados no GitHub

## Riscos e mitigacoes
- PAT atrelado a usuario: mitigar documentando rotacao e planejando migrar para GitHub App no futuro
- OIDC issuer do K3s nao publico: image pull secret usa SA key via Secret Manager (mesmo workaround do ESO)
- reusable workflow no homelab-gitops: precisa de versionamento cuidadoso para nao quebrar callers existentes
