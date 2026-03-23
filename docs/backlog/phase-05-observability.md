# Phase 05 - Observabilidade base da plataforma

## Resumo executivo
Esta fase estabelece a camada inicial de observabilidade do homelab com foco em metricas e dashboards operacionais, sem complexidade enterprise. A implementacao recomendada usa `kube-prometheus-stack` via Argo CD, no escopo compartilhado do cluster, com configuracao conservadora para K3s single-node.

Resultado pratico esperado:
- visibilidade de saude do cluster
- visibilidade de CPU/memoria/disco do node
- visibilidade de estado de pods e namespaces
- acompanhamento de restarts e falhas basicas
- base pronta para onboarding de app de teste real na fase seguinte

## Objetivo da fase
Implantar observabilidade minima, util e sustentavel para operacao diaria do cluster unico atual, mantendo compatibilidade com expansao futura (mais ambientes logicos e, depois, multiplos clusters).

## Escopo da phase-05

### Incluido
- Prometheus para coleta de metricas de plataforma e workloads
- Grafana para visualizacao com dashboards iniciais
- Exporters/componentes necessarios para metricas de node e recursos Kubernetes
- Organizacao GitOps da observabilidade no escopo `shared`
- Documentacao operacional e de aceite da fase

### Fora do escopo
- stack completa de logging centralizado (Loki/EFK)
- tracing distribuido (OpenTelemetry/Jaeger/Tempo)
- alertamento avancado e operacao SRE completa
- multi-cluster observability
- integracao com GCP Monitoring
- hardening avancado para exposicao publica de dashboards

### Evolucao posterior planejada
- logging centralizado com retencao controlada
- alertas progressivos por severidade
- tracing para workloads de negocio
- padrao de observabilidade para ambiente cloud e fleet hibrido

## Arquitetura recomendada

### Topologia logica
- cluster unico K3s single-node
- observabilidade centralizada em namespace compartilhado `observability`
- workloads de negocio segregados por namespaces (`dev-apps`, `prd-apps`)
- stack de observabilidade instalada por Argo CD como recurso de plataforma (`shared`)

### Componentes e posicao
- `Argo CD Application` (namespace `argocd`): declara e reconcilia a stack
- `Prometheus` (namespace `observability`): coleta metricas de cluster, node e workloads
- `kube-state-metrics` (namespace `observability`): metricas de objetos Kubernetes (pods, deployments, restarts, status)
- `node-exporter` (DaemonSet, namespace `observability`): metricas de host/node
- `Grafana` (namespace `observability`): dashboards operacionais iniciais

### Por que esta arquitetura
- centraliza observabilidade no escopo compartilhado e evita duplicacao por ambiente logico
- preserva separacao `dev`/`prd` por labels/namespaces, sem criar novos clusters
- simplifica operacao em homelab e reduz custo cognitivo
- permite evolucao futura para topologias mais complexas sem retrabalho conceitual

## Stack recomendada

### Opcao recomendada: kube-prometheus-stack
Recomendacao para esta fase:
- `kube-prometheus-stack` (Prometheus Operator + Prometheus + Grafana + exporters essenciais)

Justificativa:
- pacote consolidado e amplamente usado
- reduz esforco de integracao manual entre componentes
- entrega dashboards e ServiceMonitors prontos para o bootstrap inicial
- facilita GitOps com um unico chart e values controlados

Trade-offs:
- mais pesado que instalar Prometheus/Grafana isolados
- exige controle de resources e retencao para caber no single-node

### Alternativa viavel: Prometheus + Grafana "manual"
Vantagens:
- menor footprint potencial
- maior controle fino de cada componente

Desvantagens:
- aumenta complexidade operacional e risco de configuracao incompleta
- maior custo de manutencao no curto prazo

Conclusao:
Para o momento atual do homelab, `kube-prometheus-stack` enxuto oferece melhor relacao simplicidade x valor operacional.

## Estrategia por namespaces e ambientes

### O que fica em shared
- namespace `observability`
- stack de metricas/dashboards
- componentes cluster-wide de coleta

### Como observar dev e prd no mesmo cluster
- metricas centralizadas no Prometheus unico
- filtros por namespace e labels (`homelab.io/environment`) nos dashboards
- visao comparativa de `dev` e `prd` sem duplicar stack

### Como evitar acoplamento ruim para expansao futura
- manter observabilidade como aplicacao de plataforma separada de workloads
- manter naming e labels consistentes por ambiente
- manter possibilidade de trocar de "prometheus unico" para "federacao/remoto" em fases futuras

## Estrategia GitOps

### Encaixe na hierarquia atual
- manter `bootstrap/root` como app-of-apps raiz
- manter `shared-platform` como agregador de componentes compartilhados
- adicionar `shared-observability` como `Application` filha dentro de `shared-platform`

### Recursos gerenciados por Argo CD
- `Application` da observabilidade em `argocd`
- release Helm do `kube-prometheus-stack`
- namespace `observability` criado via `CreateNamespace=true`

### Diretriz de organizacao
- tudo que for observabilidade base da plataforma permanece em `gitops/apps/shared/platform`
- customizacoes de workloads continuam nos caminhos de `dev` e `prd`

## Estrutura sugerida de diretorios e arquivos

Estrutura-alvo desta fase:

```text
gitops/
  bootstrap/
    root/
      applications/
        shared-platform.yaml
  apps/
    shared/
      platform/
        kustomization.yaml
        manifests/
          bootstrap-configmap.yaml
          observability-kube-prometheus-stack.yaml
```

Observacao:
- neste inicio, os values Helm estao inline no `Application` para reduzir moving parts
- quando houver aumento de customizacoes, evoluir para arquivo de values dedicado no mesmo escopo

## Plano de implementacao

1. Validar pre-condicoes
- confirmar cluster `Ready` e Argo CD saudavel
- confirmar sincronizacao do app raiz

2. Preparar escopo compartilhado
- adicionar recurso GitOps da observabilidade em `shared-platform`
- manter destino no namespace `observability`

3. Configurar stack com perfil enxuto
- desabilitar `alertmanager` nesta fase
- configurar retencao curta no Prometheus (`2d`)
- definir requests/limits conservadores

4. Sincronizar no Argo CD
- validar status `Synced` e `Healthy` do `shared-observability`
- validar criacao dos pods principais

5. Validar acesso e metricas
- acessar Grafana (port-forward ou exposicao interna controlada)
- validar dashboards de node, Kubernetes compute e workloads
- validar visao de restarts e falhas por namespace

6. Registrar evidencias
- capturar evidencias de sync/health do Argo CD
- registrar dashboards validados e consultas usadas

7. Fechar fase
- atualizar `tasks/current-focus.md`
- atualizar `docs/architecture/roadmap.md`
- registrar criterios de aceite como concluidos

## Criterios de aceite
- `shared-observability` presente no Argo CD
- aplicacao de observabilidade em `Synced` e `Healthy`
- Prometheus coletando metricas de node e objetos Kubernetes
- Grafana acessivel com dashboards iniciais funcionais
- visibilidade de namespaces `dev` e `prd` no mesmo cluster
- visualizacao de restarts/falhas basicas de pods
- documentacao da fase criada e atualizada

## Status de execucao (2026-03-23)

### Concluido
- aplicacao `shared-observability` sincronizada no Argo CD
- stack minima de metricas operacional (Prometheus + Grafana + exporters)
- dashboards de node/namespace/pod validados no Grafana
- metricas de restart/falha basica confirmadas
- app de teste em `dev` validado com endpoints de sucesso e erro
- logs de aplicacao confirmados no cluster (stdout/stderr)

### Em aberto
- visualizacao de logs de aplicacao no Grafana

### Decisao de rollout
- manter workload de teste apenas em `dev`
- adiar promocao para `prd` ate consolidar pipeline de logs

### Pendencias para trilha de logs
- implantar Loki (backend de logs) no escopo compartilhado
- implantar Grafana Alloy como agente coletor
- configurar labels e pipeline de envio Alloy -> Loki
- validar consultas no Grafana Explore por `namespace` e `app`
- definir retencao de logs adequada ao limite de disco do homelab

## Riscos e cuidados
- risco de consumo excessivo de CPU/memoria no single-node
- risco de uso de armazenamento acima do esperado por retencao alta
- risco de exposicao indevida do Grafana se publicado externamente cedo demais
- risco de manter credenciais padrao do Grafana
- risco de ruido operacional por tentar cobrir alertas/logs/tracing cedo demais

Mitigacoes recomendadas:
- requests/limits conservadores desde o inicio
- retencao curta e revisao periodica
- acesso inicial interno (ClusterIP + port-forward)
- rotacao de credenciais administrativas
- evolucao incremental por fases

## Proxima fase recomendada

Sequencia sugerida apos concluir a phase-05:

1. Onboarding de app de teste real em `dev`
2. Validacao de telemetria por workload (latencia basica, erro, disponibilidade)
3. Logging centralizado enxuto
4. Alertas basicos orientados a falha real
5. Tracing para fluxos criticos
6. Evolucao gradual para cenario hibrido com cloud e, futuramente, multi-cluster