# DNS and TLS

## Objetivo
Definir estratégia mínima de nomes e certificados para:
- acesso administrativo
- Grafana
- Argo CD
- serviços do app
- endpoints cloud

## Estratégia inicial
- nomes simples e previsíveis
- priorizar acesso privado nas fases iniciais
- TLS onde houver exposição de interface administrativa

## Endpoints internos (LAN)
- Argo CD: `argocd.homelab.local`
- Grafana: `grafana.homelab.local`
- Loki (gateway): `loki.homelab.local`

Todos os nomes devem resolver para o endpoint local do Traefik no cluster.