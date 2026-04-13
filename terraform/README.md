# Terraform

Este diretorio contem a infraestrutura como codigo de bootstrap/foundation do laboratorio.

## Estrutura
- `clusters/`: entrypoints por cluster e por escopo operacional
- `modules/`: modulos reutilizaveis
- `scripts/`: comandos utilitarios
- `policies/`: politicas e anotacoes futuras

## Modelo desta fase
- `clusters/homelab/bootstrap`: recursos cluster-wide do cluster atual, incluindo instalacao do Argo CD no namespace `argocd`
- `clusters/homelab/dev`: namespaces e base do ambiente logico `dev` no cluster `homelab`
- `clusters/homelab/prd`: namespaces e base do ambiente logico `prd` no cluster `homelab`
- `clusters/ai-lab/bootstrap`: bootstrap dedicado de Argo CD para o cluster `ai-lab`, com root app proprio apontando para `clusters/ai-lab`

## Regras
- tratar `environments/` apenas como ponte historica durante a limpeza final
- concentrar logica em `modules/`
- documentar inputs e outputs
- nunca versionar segredos reais
- antes de qualquer `kubectl` ou `terraform`, selecionar explicitamente o perfil correto no shell com `use_homelab` ou `use_ailab`
- validar o perfil ativo com `kctx_status` antes de operacoes sensiveis

## Ordem recomendada
1. aplicar `clusters/homelab/bootstrap`
2. aplicar `clusters/homelab/dev`
3. aplicar `clusters/homelab/prd`

Para o `ai-lab`, executar `clusters/ai-lab/bootstrap` separadamente, usando kubeconfig e contexto do cluster alvo.

## Execucao remota (laptop administrador)
O bootstrap Terraform pode ser executado no laptop administrador. Nao e necessario abrir SSH no host apenas para rodar `terraform`.

Pre-condicoes:
- Terraform, kubectl e helm instalados no laptop
- conectividade de rede do laptop ate a API do cluster K3s
- kubeconfig administrativo valido no laptop
- contexto kubeconfig correto para o cluster alvo

Pre-condicao obrigatoria de perfil:
- `use_homelab` para `terraform/clusters/homelab/*`
- `use_ailab` para `terraform/clusters/ai-lab/bootstrap`
- `kctx_status` para verificacao explicita antes de `plan` ou `apply`

Checklist rapido:
1. `kubectl config current-context --kubeconfig <kubeconfig>`
2. `kubectl cluster-info --kubeconfig <kubeconfig>`
3. `kubectl get nodes --kubeconfig <kubeconfig>`
4. `terraform -chdir=terraform/clusters/homelab/bootstrap init -upgrade`
5. `terraform -chdir=terraform/clusters/homelab/bootstrap providers`

O script `scripts/bootstrap-order.sh` aceita variaveis de ambiente para selecionar cluster/contexto sem alterar `terraform.tfvars`:
- `KUBECONFIG`: caminho do arquivo kubeconfig
- `KUBE_CONTEXT`: contexto kubeconfig (opcional)

Exemplo:

```bash
use_homelab
kctx_status
KUBECONFIG=/home/<usuario>/.kube/config-homelab.yaml \
KUBE_CONTEXT=default \
./terraform/scripts/bootstrap-order.sh
```

## Responsabilidades
- Terraform: bootstrap/foundation e instalacao inicial do Argo CD
- `homelab-gitops/clusters/<cluster>/`: estado desejado reconciliado continuamente pelo Argo CD

## Notas operacionais recentes

### Padrao de kubeconfig por entrypoint
Para evitar erro de provider (`context "default" does not exist`), os ambientes Terraform foram padronizados para usar:

- `kubeconfig_path = "~/.kube/config-homelab.yaml"` nos entrypoints do `homelab`
- `kubeconfig_path = "~/.kube/config-ai-lab.yaml"` no bootstrap do `ai-lab`
- `pathexpand(var.kubeconfig_path)` nos providers para resolucao correta de `~`

Isso evita discrepancia entre o kubeconfig ativo no shell e o kubeconfig lido pelo Terraform.

Observacao operacional importante:
- a selecao de perfil via `use_homelab` e `use_ailab` e obrigatoria mesmo quando o arquivo `terraform.tfvars` ja aponta para um kubeconfig especifico
- isso reduz o risco de validacoes manuais com `kubectl` acontecerem no cluster errado antes ou depois do `terraform`

### Baseline de tuning do Argo CD
O modulo `modules/argocd-bootstrap` passou a aplicar baseline de estabilidade/performance para homelab:

- requests/limits para componentes principais
- `timeout.reconciliation` com jitter
- `notifications` e `dex` desabilitados por padrao
- variavel `argocd_helm_values_override` para customizacao por ambiente