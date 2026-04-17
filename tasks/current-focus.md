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
- cutover GitOps concluido para o repositorio dedicado `homelab-gitops`
- `homelab-root` e apps filhas apontando para `clusters/homelab` no repositorio GitOps dedicado
- `shared-observability` sincronizado e saudavel no Argo CD
- Prometheus e Grafana operacionais para metricas basicas da plataforma
- app de teste em `dev` (`myapp` com `httpbin`) validado com respostas de sucesso e erro
- logs da aplicacao validados no cluster (stdout/stderr via Kubernetes/Argo CD)
- rollout de workload de teste mantido apenas em `dev` neste momento

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

## Status da fase (hoje)
- phase-05 concluida para o escopo de metricas e dashboards
- validacao de app de teste em `dev` concluida (healthcheck, endpoint de erro e logs no cluster)

## Pendencias ativas (proxima etapa)
- consolidar validacao operacional da trilha de logs (Loki + Alloy + Grafana) no cluster
- registrar evidencias de consulta por namespace/app no Grafana Explore
- iniciar fase de PostgreSQL no ambiente `dev` com rollout GitOps incremental
- validar conectividade app -> banco com servico interno `ClusterIP`
- definir estrategia minima de backup/restore para o banco no homelab
- consolidar plano e execucao em `docs/backlog/phase-08-postgresql-on-cluster.md`
- manter toda mudanca GitOps em `homelab-gitops/clusters/` apos a remocao do legado

## Nota operacional paralela - Expansao do ai-lab
- estrutura GitOps `clusters/ai-lab` criada e validada em `homelab-gitops`
- discovery e pricing do `ai-lab` encerrados com decisao consolidada de seguir na GCP
- cluster K3s provisório do laptop admin/WSL descontinuado e removido do caminho arquitetural alvo
- novo entrypoint Terraform do `ai-lab`: `terraform/clusters/ai-lab/foundation`
- escopo atual do `ai-lab`: VPC, subnet, firewall restritivo, IP publico estatico, VM base, disco de dados e service account dedicada
- a arvore GitOps `clusters/ai-lab` permanece como scaffold preparado para a fase futura do cluster
- fora do escopo atual: instalacao do K3s, bootstrap do Argo CD, VPN, NAT e automacoes especificas para GPU
- proxima analise do `ai-lab` deve partir da fundacao GCP e somente depois abrir a fase de bootstrap do cluster

## Riscos e cuidados operacionais
- controlar consumo de recursos da stack (requests/limits conservadores)
- evitar retencao longa de metricas no single-node
- reduzir superficie de exposicao (preferir acesso interno/port-forward no inicio)
- evitar credenciais padrao em dashboards

## Proximo marco apos a phase-05
Consolidar logs centralizados e avancar para baseline de PostgreSQL no ambiente `dev`, mantendo rollout incremental e baixo consumo de recursos.