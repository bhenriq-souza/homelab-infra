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