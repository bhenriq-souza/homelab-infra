# Target Architecture

## Visão geral
O laboratório será composto por:
- 1 mini PC on-prem como host principal
- 1 cluster K3s local
- 1 ambiente cloud na GCP
- conectividade híbrida entre on-prem e cloud
- pipeline de CI com GitHub Actions
- Artifact Registry para imagens
- GitOps com Argo CD em repositório dedicado

## Componentes principais

### On-prem
- Ubuntu Server 24.04 LTS
- K3s single-node inicialmente
- observabilidade mínima
- serviços de apoio ao estudo de DevOps, DevSecOps e rede híbrida

### Cloud
- VPC dedicada
- VM spot inicial
- infraestrutura de apoio para testes híbridos e burst controlado

### Repositórios separados
- `homelab-infra`
- `homelab-gitops`
- `finances-app-frontend`
- `finances-app-backend`

## Objetivos técnicos
- manter simplicidade operacional
- permitir evolução por fases
- priorizar declaratividade
- facilitar trabalho com agentes de IA