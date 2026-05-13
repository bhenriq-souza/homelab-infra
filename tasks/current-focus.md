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

## Nota operacional paralela - AI Lab (workstation local)
- decisao arquitetural consolidada em ADR-0007: `ai-lab` e a workstation Ubuntu local (`192.168.15.103`), nao uma VM na GCP
- abordagem GCP para o `ai-lab` descontinuada apos falha de capacidade de GPU em multiplas regioes (ver `phase-08-ai-lab-gcp-foundation.md`)
- infraestrutura GCP do `ai-lab` destruida; Terraform em `terraform/clusters/ai-lab/foundation` mantido como referencia historica
- acesso operacional do AI Lab ao cluster homelab: SSH (`ssh homelab`) + kubeconfig (`~/.kube/config-homelab.yaml`) — validado e operacional
- estrutura GitOps `clusters/ai-lab` permanece como scaffold no `homelab-gitops` para quando o K3s for instalado no AI Lab
- proxima etapa do `ai-lab`: instalar K3s na workstation local e bootstrapar Argo CD (Fase 9)

## Riscos e cuidados operacionais
- controlar consumo de recursos da stack (requests/limits conservadores)
- evitar retencao longa de metricas no single-node
- reduzir superficie de exposicao (preferir acesso interno/port-forward no inicio)
- evitar credenciais padrao em dashboards

## Proximo marco apos a phase-05
Consolidar logs centralizados e avancar para baseline de PostgreSQL no ambiente `dev`, mantendo rollout incremental e baixo consumo de recursos.

## Proxima fase planejada - Phase 07: CI/CD Pipeline
Discovery concluido, decisoes consolidadas em ADR-0006 e implementacao parcial concluida.

### Concluido nesta fase
- Artifact Registry `homelab-apps` provisionado no GCP via Terraform (modulo `artifact-registry`)
- GitHub Actions WIF pool/provider provisionados via Terraform (modulo `gcp-github-wif`)
- SA `github-actions-ci` com `roles/artifactregistry.writer` + WIF binding para `homelab-gitops`
- SA `ar-reader` com `roles/artifactregistry.reader` + key como dockerconfigjson no Secret Manager
- ExternalSecret criando `imagePullSecret` em `dev-apps` e `prd-apps` via ESO
- Reusable workflow `docker-build-push.yaml` criado no `homelab-gitops`
- Caller workflow de teste `ci-cd-myapp.yaml` (workflow_dispatch) criado
- Dockerfile do myapp criado e imagem publicada manualmente no AR
- Deployment do myapp (dev e prd) apontando para `us-central1-docker.pkg.dev/homelab-492918/homelab-apps/myapp:latest`
- Pull de imagem privada validado com sucesso no cluster via imagePullSecret + ESO
- Secrets do GitHub configurados: `GCP_WIF_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `GITOPS_PAT`

### Aprendizados operacionais
- API `artifactregistry.googleapis.com` precisou ser habilitada manualmente (`gcp_manage_project_services = false`)
- Template ESO com `printf` e aspas escapadas causa erro de parsing; solucao: armazenar dockerconfigjson completo no Secret Manager e ExternalSecret sem template complexo
- Separacao de ambientes no gitops e por diretorio (`workloads/dev/` vs `workloads/prd/`), nao por branch do repo gitops

### Pendente para completar a fase
- validar fluxo completo via GitHub Actions (workflow_dispatch do myapp)
- criar caller workflow no primeiro app repo real (`finances-control-backend`)
- validar rollback via revert de commit no homelab-gitops
- documentar inputs do reusable workflow

Referencia: `docs/backlog/phase-07-cicd-pipeline.md` e `docs/adr/ADR-0006-cicd-with-github-actions-and-artifact-registry.md`