# Phase 06 - Logs centralizados (Loki + Grafana Alloy)

## Resumo executivo
Esta fase implanta uma trilha de logs centralizados enxuta para o homelab, mantendo simplicidade operacional e baixo consumo de recursos. O objetivo e habilitar consulta de logs de aplicacao no Grafana usando Loki como backend e Grafana Alloy como agente coletor.

Estado de partida:
- metricas e dashboards basicos ja estao operacionais
- app de teste em `dev` validado
- logs ja existem no cluster (stdout/stderr)

Resultado esperado:
- logs de aplicacao pesquisaveis no Grafana
- filtros por namespace/app/pod
- pipeline observavel e de facil troubleshooting

## Objetivo da fase
Centralizar logs do cluster no Grafana de forma incremental, priorizando confiabilidade minima e controle de custo para ambiente K3s single-node.

## Escopo da fase

### Incluido
- backend de logs com Loki (perfil homelab)
- coleta de logs com Grafana Alloy
- labels minimas para busca operacional
- datasource Loki no Grafana
- validacao operacional com app de teste em `dev`
- documentacao de operacao e troubleshooting

### Fora do escopo
- HA de Loki
- SIEM/correlacao avancada
- parsing complexo de multiplos formatos
- alertas avancados baseados em logs
- retencao longa

## Arquitetura recomendada

### Topologia
1. workloads escrevem logs em stdout/stderr
2. Grafana Alloy coleta logs nos nodes e metadados Kubernetes
3. Alloy envia logs para Loki
4. Grafana consulta Loki via datasource

### Posicionamento dos componentes
- Loki em escopo compartilhado (`shared`)
- Alloy em escopo compartilhado (`shared`), com coleta cluster-wide
- consultas segmentadas por labels de namespace/app/ambiente

### Labels minimas recomendadas
- `cluster`
- `namespace`
- `pod`
- `container`
- `app`
- `environment`

## Estrategia por ambientes
- pipeline de logs unico no cluster (escopo compartilhado)
- validacao inicial apenas em `dev`
- promocao para `prd` apenas apos estabilizar consumo e consultas
- manter separacao logica por labels e namespaces

## Estrategia GitOps

### Recursos que serao gerenciados por Argo CD
- aplicacao de plataforma para Loki
- aplicacao de plataforma para Grafana Alloy
- configuracao de datasource Loki no Grafana

### Ordem de rollout recomendada
1. Loki
2. Alloy
3. datasource Loki no Grafana
4. validacao no Explore

Decisao para o ambiente atual (dev):
- materializacao completa em um unico ciclo GitOps
- sem rollout incremental por lotes
- ainda mantendo ordem tecnica de dependencia durante o sync

## Materializacao GitOps desta fase

### Artefatos aplicados
- `gitops/apps/shared/platform/manifests/shared-logging-loki.yaml`
- `gitops/apps/shared/platform/manifests/shared-logging-alloy.yaml`
- `gitops/apps/shared/platform/manifests/observability-kube-prometheus-stack.yaml` (datasource Loki)
- `gitops/apps/shared/platform/kustomization.yaml` (inclusao dos novos recursos)

### Parametros operacionais definidos
- Loki em modo `SingleBinary`, sem HA, com retencao inicial de 7 dias
- persistencia local inicial de 10Gi
- Alloy em DaemonSet, coletando logs de pods/containers via host paths
- labels minimas no pipeline: `cluster`, `namespace`, `pod`, `container`, `app`, `environment`

## Plano de implementacao incremental

### L1 - Foundation
1. definir budget de CPU/memoria/disco
2. definir retencao inicial de logs
3. definir labels obrigatorias

### L2 - Loki base
1. implantar Loki em modo simples
2. configurar retencao curta
3. validar saude e ingestao

### L3 - Alloy coleta
1. implantar Alloy com coleta de logs de containers
2. enriquecer com labels Kubernetes essenciais
3. validar envio Alloy -> Loki

### L4 - Grafana integracao
1. adicionar datasource Loki
2. validar consultas por `namespace`, `app`, `pod`
3. salvar consultas operacionais padrao

### L5 - Validacao operacional
1. gerar trafego de sucesso e erro no app de teste em `dev`
2. confirmar logs no Grafana Explore
3. validar latencia de ingestao
4. registrar aceite da fase

## Criterios de aceite
- Loki operacional no cluster
- Alloy coletando logs de containers
- logs do `myapp` em `dev` visiveis no Grafana
- consultas por namespace/app/pod funcionando
- retencao e consumo dentro dos limites definidos
- runbook de operacao e troubleshooting atualizado

## Validacao rapida pos-materializacao
1. Confirmar sincronizacao das aplicacoes no Argo CD (`shared-platform` e filhos de observabilidade/logging).
2. Validar pods e estado basico:
	- `kubectl -n observability get pods`
	- `kubectl -n observability get pvc`
3. Gerar trafego de teste no `myapp` em `dev`:
	- `kubectl -n dev-apps logs deploy/myapp --tail=100`
4. No Grafana Explore, consultar em Loki:
	- `{namespace="dev-apps", app="myapp"}`
	- `{namespace="dev-apps", pod=~"myapp-.*"}`
5. Confirmar latencia de ingestao e aderencia das labels obrigatorias.

## Riscos e cuidados
- risco de consumo excessivo de disco
- risco de pressao de CPU/memoria no single-node
- risco de cardinalidade alta em labels
- risco de exposicao de dados sensiveis em logs

Mitigacoes:
- retencao curta e volume controlado
- requests/limits conservadores
- labels estaveis e estritamente necessarias
- revisao de acesso e conteudo de logs

## Rollback minimo
1. desativar coletor (Alloy) em caso de pressao no node
2. reduzir retencao do Loki
3. manter fallback operacional com `kubectl logs`
4. reintroduzir pipeline gradualmente

## Proxima fase apos logs
Com pipeline de logs estavel, avancar para automacao e entrega (CI/CD de infra) e, depois, alertas basicos orientados a incidentes reais.