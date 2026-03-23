# Current Focus

## Fase ativa
Phase 05 - Observabilidade base da plataforma

## Objetivo da fase
Implantar uma camada inicial de observabilidade orientada a operacao para o cluster K3s single-node, com foco em metricas e dashboards basicos via GitOps, mantendo baixo custo operacional para homelab.

## Estado atual consolidado
- host on-prem em Ubuntu Server 24.04 operacional
- cluster K3s single-node funcional
- segregacao logica por namespaces (`shared`, `dev`, `prd`)
- base Terraform criada com entrypoints `shared`, `dev` e `prd`
- Argo CD bootstrapado com Terraform
- sincronizacao Argo CD <-> repositorio validada
- workloads de exemplo em `dev`/`prd` podem falhar por imagem ausente no registry, sem bloquear observabilidade

## Escopo desta fase (phase-05)
- adicionar stack inicial de metricas e dashboards no escopo compartilhado do cluster
- observar saude do cluster e do node (CPU, memoria, disco)
- observar estado de pods e namespaces, incluindo restarts e falhas basicas
- estruturar a entrega via Argo CD, sem desviar do padrao GitOps atual
- documentar arquitetura, trade-offs, plano de execucao e criterios de aceite

## Fora do escopo desta fase
- logging centralizado completo
- tracing distribuido
- alertas avancados e operacao SRE madura
- multi-cluster, fleet e integracao com GCP Monitoring
- hardening avancado de exposicao externa de dashboards

## Entregaveis imediatos
- documentacao da phase-05 com arquitetura recomendada e plano detalhado
- atualizacao do roadmap com sequencia de fases coerente ao estado real
- aplicacao GitOps da observabilidade no escopo `shared`
- configuracao inicial enxuta para homelab single-node

## Criterios de conclusao da fase
- aplicacao de observabilidade criada e sincronizando no Argo CD
- Prometheus coletando metricas de node e workloads do cluster
- Grafana acessivel para operacao inicial
- dashboards iniciais com visibilidade de node, pods e namespaces
- documentacao principal atualizada (`current-focus`, roadmap e backlog da fase)

## Riscos e cuidados operacionais
- controlar consumo de recursos da stack (requests/limits conservadores)
- evitar retencao longa de metricas no single-node
- reduzir superficie de exposicao (preferir acesso interno/port-forward no inicio)
- evitar credenciais padrao em dashboards

## Proximo marco apos a phase-05
Entrar na fase de validacao com app de teste real para confirmar telemetria por workload e, na sequencia, evoluir para logging centralizado e alertas.