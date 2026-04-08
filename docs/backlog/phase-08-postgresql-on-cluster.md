# Phase 08 - PostgreSQL no cluster (dev -> prd)

## Resumo executivo
Esta fase estabelece a base de banco de dados PostgreSQL no cluster do homelab para suportar integracao de aplicacoes, com rollout incremental: primeiro `dev`, depois `prd`.

Principios desta fase:
- simplicidade operacional para K3s single-node
- sem exposicao externa do banco
- segredos fora de versionamento em texto puro
- validacao de backup/restore antes de promocao para `prd`

## Objetivo da fase
Implantar e configurar PostgreSQL com GitOps no ambiente `dev`, validar conectividade e operacao minima, e preparar criterios de promocao para `prd`.

## Escopo

### Incluido
- PostgreSQL single-instance no namespace `dev-apps`
- Service interno `ClusterIP`
- persistencia com PVC
- parametros basicos de recursos (requests/limits)
- runbook inicial de validacao operacional
- estrategia inicial de backup logico e teste de restore

### Fora do escopo
- HA de banco
- replicacao cross-cluster
- tuning avancado de performance
- exposicao publica do banco
- operacao multi-cluster

## Arquitetura recomendada (fase inicial)
- workload de banco no escopo `dev-apps`
- StatefulSet com volume persistente
- Service interno para conexao de workloads
- Secret Kubernetes para credenciais
- controle de acesso de rede por namespace/pod (quando suportado no cluster)

## Estrategia de rollout
1. aplicar baseline de PostgreSQL em `dev`
2. validar readiness/liveness, persistencia e conectividade
3. validar backup e restore em ambiente de teste
4. promover para `prd` com parametros mais restritivos

## Criterios de aceite
- PostgreSQL em `dev` sincronizado e saudavel via Argo CD
- app de teste conectando e executando operacoes basicas
- sem exposicao externa do banco
- evidencias de backup e restore registradas
- documentacao operacional atualizada

## Riscos e mitigacoes
- risco de perda de dados por falha de disco local:
  - mitigar com backup frequente + teste recorrente de restore
- risco de uso excessivo de recursos no single-node:
  - mitigar com requests/limits conservadores e monitoramento
- risco de credenciais expostas:
  - mitigar com Secrets e politica de nao versionar segredo real

## Plano de execucao
1. criar manifests GitOps de PostgreSQL em `gitops/apps/dev/workloads`
2. sincronizar e validar estado do StatefulSet/PVC/Service
3. executar teste de conectividade no namespace `dev-apps`
4. documentar runbook de operacao e troubleshooting
5. preparar gates de promocao para `prd`
