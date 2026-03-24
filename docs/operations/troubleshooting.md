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
1. Executar `terraform -chdir=terraform/environments/shared providers`
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
	- `terraform/environments/shared/variables.tf` (`argocd_helm_values_override`)

### Validacao pos-correcao
1. Reaplicar `shared`:

```bash
terraform -chdir=terraform/environments/shared plan
terraform -chdir=terraform/environments/shared apply
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