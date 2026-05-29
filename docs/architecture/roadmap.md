# Roadmap

## Fase 0 - Arquitetura
- definir arquitetura alvo
- definir convenções
- registrar ADRs iniciais

## Fase 1 - Host
- instalar Ubuntu Server
- aplicar hardening básico
- configurar acesso remoto

## Fase 2 - Rede
- planejar LAN local
- planejar conectividade híbrida
- definir ranges IP e exposição

## Fase 3 - Cluster local
- instalar K3s
- validar kubeconfig
- preparar namespaces base

## Fase 4 - Fundacao IaC + GitOps
- estruturar Terraform por escopo `shared` / `dev` / `prd`
- bootstrapar Argo CD no cluster local
- validar fluxo app-of-apps e sincronizacao com Git

## Fase 5 - Observabilidade base
- instalar stack minima de metricas e dashboards
- cobrir saude do node, cluster, pods e namespaces
- manter configuracao enxuta para K3s single-node

## Fase 6 - Logs centralizados
- implantar Loki para backend de logs
- implantar Grafana Alloy para coleta de logs
- habilitar consulta de logs no Grafana

## Fase 7 - CI/CD Pipeline
- provisionar Artifact Registry no GCP (modulo Terraform)
- configurar GitHub OIDC -> GCP WIF para GitHub Actions
- criar image pull secrets via ESO nos namespaces dev-apps e prd-apps
- implementar reusable workflow em homelab-gitops
- validar fluxo end-to-end: push -> build -> deploy via Argo CD
- segregacao de branch: develop -> dev, main -> prd

## Fase 8 - Integracao com o app
- preparar contratos de infra para frontend/backend
- definir naming esperado de artefatos
- definir dependências operacionais do app
- estabelecer baseline de banco de dados PostgreSQL no cluster (dev -> prd)
- validar estratégia de backup/restore do banco antes da promoção para produção

## Fase 9 - AI Lab e fleet
- ~~formalizar o `ai-lab` como nó da LAN local~~ — **concluído**: IP `192.168.15.103` com DHCP reservado no MitraStar (ver ADR-0007)
- ~~configurar acesso operacional completo do `ai-lab` ao cluster `homelab` (SSH + kubeconfig)~~ — **concluído**
- instalar K3s no `ai-lab` e bootstrapar Argo CD
- ativar `clusters/ai-lab` no repositório GitOps como cluster gerenciado
- preparar base para gestão multi-cluster (homelab + ai-lab)
- padronizar bootstrap do Argo CD por cluster
