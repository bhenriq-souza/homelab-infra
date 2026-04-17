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

## AI Lab - tentativa prematura de bootstrap do cluster

### Sintoma
- alguem tenta usar `use_ailab`, kubeconfig do `ai-lab` ou um bootstrap de Argo CD antes do cluster existir na GCP
- surgem referencias a `terraform/clusters/ai-lab/bootstrap`, `~/.kube/config-ai-lab.yaml` ou `ai-lab-root`

### Contexto operacional correto
- o cluster local provisório do `ai-lab` em Ubuntu/WSL foi descontinuado
- a etapa atual do `ai-lab` e somente a fundacao GCP em `terraform/clusters/ai-lab/foundation`
- nao existe kubeconfig do `ai-lab` valido nesta fase
- nao existe root app do Argo CD ativo para o `ai-lab` nesta fase

### Passos de validacao
1. Confirmar o entrypoint correto da fase atual:

```bash
ls terraform/clusters/ai-lab
terraform -chdir=terraform/clusters/ai-lab/foundation validate
```

2. Confirmar que o artefato local do kubeconfig nao deve mais existir:

```bash
test ! -f ~/.kube/config-ai-lab.yaml
```

3. Validar se o proximo passo esperado ainda e fundacao cloud:

```bash
terraform -chdir=terraform/clusters/ai-lab/foundation plan
```

### Acao corretiva
- nao recriar kubeconfig do `ai-lab` nesta etapa
- nao reintroduzir bootstrap do Argo CD antes da instalacao futura do K3s
- seguir com a fundacao GCP e abrir uma nova fase apenas quando a VM estiver pronta para receber o cluster

## AI Lab - GPU T4 indisponivel apesar de quota regional

### Sintoma
- `terraform apply` falha ao criar a VM do `ai-lab` com `n1-standard-8` e `1 x nvidia-tesla-t4`
- a falha ocorre depois da validacao do Terraform e mesmo com quota regional de T4 disponivel
- mensagens tipicas:

```text
The zone '.../zones/<zone>' does not have enough resources available to fulfill the request.
A n1-standard-8 VM instance with 1 nvidia-tesla-t4 accelerator(s) is currently unavailable...
```

### Possiveis causas
- indisponibilidade momentanea de capacidade fisica na zona
- combinacao de machine type e GPU aceita no catalogo, mas sem estoque real naquele momento
- variacao de suporte efetivo por zona, mesmo dentro da mesma regiao

### Passos de validacao
1. Confirmar que a combinacao existe no catalogo da zona:

```bash
gcloud compute machine-types describe n1-standard-8 --zone <zone>
gcloud compute accelerator-types describe nvidia-tesla-t4 --zone <zone>
```

2. Confirmar quota regional:

```bash
gcloud compute regions describe <region> --format='yaml(quotas)'
```

3. Gerar `plan` salvo antes de aplicar:

```bash
terraform -chdir=terraform/clusters/ai-lab/foundation plan -input=false -out=tfplan
terraform -chdir=terraform/clusters/ai-lab/foundation apply -input=false -auto-approve tfplan
```

4. Se a VM anterior ja tiver sido removida, validar rapidamente o que ainda restou em estado:

```bash
terraform -chdir=terraform/clusters/ai-lab/foundation state list
```

### Historico observado
- `us-central1-a`, `us-central1-b`, `us-central1-c`, `us-central1-f`
- `us-east1-b`, `us-east1-c`, `us-east1-d`
- `us-east4-b`
- `europe-west1-b`, `europe-west1-c`, `europe-west1-d`

Todas as tentativas acima falharam por indisponibilidade/capacidade para `n1-standard-8 + 1 x T4`.

### Acao corretiva
- nao insistir em `apply` repetidos na mesma zona quando o erro for claramente de capacidade
- preferir uma destas saidas:
	- recriar temporariamente a VM sem GPU para restaurar o ambiente
	- testar outra combinacao de machine type/GPU
	- pausar a entrega e retomar com nova estrategia de capacity planning

### Acao de rollback usada
- executar `terraform destroy -input=false -auto-approve` no entrypoint da foundation
- confirmar estado vazio com:

```bash
terraform -chdir=terraform/clusters/ai-lab/foundation state list
```

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