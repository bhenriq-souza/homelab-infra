# Troubleshooting

## Objetivo
Registrar problemas recorrentes, hipóteses comuns e formas de validação.

## Estrutura sugerida
- sintoma
- possíveis causas
- passos de validação
- ação corretiva

## Terraform bootstrap - provider kubectl invalido

### Sintoma
Erro durante `terraform init` no ambiente `shared`:

```text
Could not retrieve the list of available versions for provider hashicorp/kubectl
Did you intend to use gavinbunney/kubectl?
```

### Possiveis causas
- modulo Terraform sem `required_providers` explicito para `kubectl`
- resolucao implicita para `hashicorp/kubectl` em vez de `gavinbunney/kubectl`

### Passos de validacao
1. Executar `terraform -chdir=terraform/clusters/homelab/bootstrap providers`
2. Confirmar se aparece `hashicorp/kubectl` na arvore de providers
3. Conferir se o modulo usado por `shared` declara `source = "gavinbunney/kubectl"`

### Acao corretiva
- Declarar `required_providers` no modulo que usa `kubectl_manifest`
- Garantir `kubectl` com source `gavinbunney/kubectl`
- Rodar `terraform init -upgrade` novamente no ambiente afetado

Referencia do modulo:
- `terraform/modules/argocd-bootstrap/versions.tf`

## Terraform bootstrap - contexto Kubernetes inexistente

### Sintoma
Erro durante `terraform plan`/`apply`:

```text
Provider configuration: cannot load Kubernetes client config
context "default" does not exist
```

### Possiveis causas
- provider lendo arquivo diferente do kubeconfig esperado
- `kubeconfig_path` padrao apontando para `~/.kube/config` enquanto o arquivo real esta em outro caminho
- contexto informado em `kubeconfig_context` nao existe no arquivo carregado

### Passos de validacao
1. Verificar contexto e server no arquivo desejado:
	- `kubectl config get-contexts --kubeconfig <kubeconfig>`
	- `kubectl config current-context --kubeconfig <kubeconfig>`
2. Validar conectividade:
	- `kubectl cluster-info --kubeconfig <kubeconfig>`
	- `kubectl get nodes --kubeconfig <kubeconfig>`
3. Confirmar caminho/contexto efetivos usados no Terraform:
	- `echo $KUBECONFIG`
	- `echo $KUBE_CONTEXT`

### Acao corretiva
- Executar o bootstrap informando `KUBECONFIG` e, quando necessario, `KUBE_CONTEXT`
- Ou definir `kubeconfig_path`/`kubeconfig_context` no `terraform.tfvars` de cada ambiente

Exemplo de execucao:

```bash
KUBECONFIG=/home/<usuario>/.kube/config-homelab.yaml \
KUBE_CONTEXT=default \
./terraform/scripts/bootstrap-order.sh
```

Observacao operacional:
- o bootstrap Terraform pode ser executado do laptop administrador, sem SSH no host, desde que haja conectividade com a API do cluster e kubeconfig valido.

## Argo CD lento ou com crash durante sync

### Sintoma
- sincronizacao lenta ao reconciliar mudancas no repositorio GitOps
- pod(s) do Argo CD reiniciando com frequencia durante picos de sync
- UI com varias reconexoes de stream (`Watch`/`WatchResourceTree`)

### Possiveis causas
- pressao de memoria/CPU em `argocd-application-controller` e `argocd-repo-server`
- reconciliacao muito frequente para o tamanho do cluster/repo
- componentes opcionais habilitados sem uso (ex.: notifications/dex)

### Passos de validacao
1. Verificar reinicios e motivo de terminacao dos pods:

```bash
kubectl -n argocd get pods
kubectl -n argocd describe pod <pod-name> | grep -E "Reason|Last State|OOMKilled|Exit Code"
```

2. Verificar eventos recentes no namespace `argocd`:

```bash
kubectl -n argocd get events --sort-by=.lastTimestamp | tail -n 30
```

3. Inspecionar uso de CPU/memoria durante sync:

```bash
kubectl -n argocd top pod
```

4. Confirmar configuracao efetiva do chart:

```bash
helm -n argocd get values argocd -a
```

### Acao corretiva
- aplicar o baseline de tuning no modulo Terraform:
	- `terraform/modules/argocd-bootstrap/main.tf`
- baseline inclui:
	- requests/limits para `controller`, `repoServer`, `server`, `applicationSet` e `redis`
	- `timeout.reconciliation=300s` e `timeout.reconciliation.jitter=60s`
	- `notifications.enabled=false` e `dex.enabled=false` (quando nao utilizados)
- caso necessario, ajustar override por ambiente em:
	- `terraform/clusters/homelab/bootstrap/variables.tf` (`argocd_helm_values_override`)
- para uso diario da UI, preferir exposicao por Ingress/TLS em vez de `kubectl port-forward` recorrente, reduzindo instabilidade de streams gRPC em redes com jitter.

### Validacao pos-correcao
1. Reaplicar `shared`:

```bash
terraform -chdir=terraform/clusters/homelab/bootstrap plan
terraform -chdir=terraform/clusters/homelab/bootstrap apply
```

2. Forcar uma sincronizacao de app com mudanca pequena e observar estabilidade:

```bash
kubectl -n argocd get pods -w
kubectl -n argocd logs deploy/argocd-application-controller --tail=200 -f
```

3. Criterio de sucesso:
- sem novos `CrashLoopBackOff` no namespace `argocd`
- tempo de sync reduzido/estavel para apps do bootstrap
- ausencia de novos eventos de `OOMKilled`

## AI Lab - tentativa prematura de bootstrap do cluster K3s

### Sintoma
- alguem tenta usar `use_ailab`, `~/.kube/config-ai-lab.yaml` ou configurar root app do Argo CD antes do K3s estar instalado na workstation AI Lab

### Contexto operacional correto (ADR-0007)
- o `ai-lab` e a workstation Ubuntu local (`192.168.15.103`), nao uma VM na GCP
- o K3s ainda nao esta instalado na workstation — essa e a proxima etapa (Fase 9)
- nao existe kubeconfig valido para o `ai-lab` nesta fase
- nao existe root app do Argo CD ativo para o `ai-lab` nesta fase
- a estrutura `clusters/ai-lab` no repositorio GitOps e um scaffold preparado, nao um cluster ativo

### Passos de validacao
1. Confirmar que o K3s ainda nao esta instalado no AI Lab:

```bash
# no AI Lab (192.168.15.103)
which k3s || echo "k3s nao instalado"
```

2. Confirmar que o kubeconfig do AI Lab nao existe:

```bash
test ! -f ~/.kube/config-ai-lab.yaml && echo "correto — ai-lab ainda nao tem cluster"
```

### Acao corretiva
- nao criar kubeconfig do `ai-lab` ate o K3s ser instalado
- nao reintroduzir bootstrap do Argo CD antes da instalacao do K3s
- consultar o backlog em `docs/backlog/phase-08-hybrid-fleet.md` para os proximos passos da Fase 9

## AI Lab - historico de tentativas GCP (encerrado)

> **Esta secao e apenas registro historico.** A abordagem de hospedar o `ai-lab` na GCP foi descontinuada (ADR-0007). O `ai-lab` e agora a workstation Ubuntu local com RTX 5070.

### Contexto
- foram tentadas VMs `n1-standard-8 + 1x nvidia-tesla-t4` em 11 regioes/zonas do GCP
- o bloqueio foi de capacidade real do Compute Engine, nao de quota nem de sintaxe Terraform
- a infraestrutura GCP do `ai-lab` foi destruida via `terraform destroy` ao final das tentativas
- o estado Terraform em `terraform/clusters/ai-lab/foundation` ficou vazio apos o rollback

### Regioes e zonas tentadas (todas falharam)
- `us-central1-a/b/c/f`, `us-east1-b/c/d`, `us-east4-b`, `europe-west1-b/c/d`

### Decisao tomada
- abandonar abordagem GCP para o AI Lab
- usar workstation Ubuntu local como AI Lab (hardware: RTX 5070 12 GB GDDR7, Ryzen 9 7900X, 64 GB DDR5)
- ver `docs/adr/ADR-0007-host-ai-lab-on-local-ubuntu.md` e `docs/backlog/phase-08-ai-lab-gcp-foundation.md`

## PostgreSQL em dev - pod nao fica pronto

### Sintoma
- pod `postgresql-0` fica em `CrashLoopBackOff` ou `Pending`
- readiness/liveness falhando

### Possiveis causas
- PVC nao foi provisionado ou nao ficou `Bound`
- credenciais invalidas no Secret `postgresql-auth`
- limite de recursos insuficiente no node

### Passos de validacao
1. Verificar estado geral dos recursos:

```bash
kubectl -n dev-apps get statefulset,pod,pvc,events --sort-by=.lastTimestamp
```

2. Verificar logs do pod:

```bash
kubectl -n dev-apps logs statefulset/postgresql --tail=200
```

3. Verificar Secret carregado no namespace:

```bash
kubectl -n dev-apps get secret postgresql-auth -o yaml
```

4. Validar pressao de recursos no cluster:

```bash
kubectl top node
kubectl -n dev-apps top pod
```

### Acao corretiva
- corrigir credenciais no Secret e ressincronizar o app
- ajustar requests/limits do StatefulSet para o perfil do host
- revisar StorageClass/PV local quando PVC nao estiver `Bound`