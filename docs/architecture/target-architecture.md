# Target Architecture

## Visão geral
O laboratório é composto por:
- 1 mini PC on-prem como host principal do cluster K3s (`homelab`)
- 1 workstation Ubuntu local como ambiente de desenvolvimento e AI (`ai-lab`)
- GCP como plataforma de CI/CD e gestão de artefatos
- pipeline de CI com GitHub Actions
- Artifact Registry para imagens
- GitOps com Argo CD em repositório dedicado

## Componentes principais

### On-prem — homelab
- Ubuntu Server 24.04 LTS no mini PC `hlb-beelink01` (`192.168.15.97`)
- K3s single-node
- observabilidade mínima (Prometheus + Grafana + Loki)
- serviços de apoio ao estudo de DevOps, DevSecOps e plataforma

### On-prem — ai-lab
- Workstation Ubuntu do operador (`192.168.15.103`)
- mesma LAN que o homelab — acesso direto ao cluster K3s sem VPN
- GPU local para cargas de IA (Ollama e afins)
- K3s planejado para fase futura; scaffold GitOps versionado em `homelab-gitops/clusters/ai-lab`

### Cloud (GCP)
- Artifact Registry para imagens privadas de container
- WIF e service accounts para autenticação sem credenciais de longa duração
- Secret Manager para segredos operacionais (image pull secrets)
- sem VM dedicada para o `ai-lab` nesta arquitetura (ver ADR-0007)

### Repositórios separados
- `homelab-infra`
- `homelab-gitops`
- `finances-app-frontend`
- `finances-app-backend`

Status atual:
- `homelab-infra`: documentação, backlog, Terraform e contexto operacional
- `homelab-gitops`: fonte ativa de verdade do Argo CD para o cluster `homelab`

## Objetivos técnicos
- manter simplicidade operacional
- permitir evolução por fases
- priorizar declaratividade
- facilitar trabalho com agentes de IA
