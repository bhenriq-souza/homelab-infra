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

## Fase 6 - Entrega e automação
- preparar CI de infraestrutura
- integrar com demais repositórios

## Fase 7 - Integração com o app
- preparar contratos de infra para frontend/backend
- definir dependências operacionais do app

## Fase 8 - Híbrido e fleet
- consolidar conectividade on-prem + cloud
- preparar base para gestão multi-cluster