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
- `clusters/ai-lab/foundation`: fundacao GCP do `ai-lab` para suportar a futura instalacao do K3s

## Regras
- tratar `environments/` apenas como ponte historica durante a limpeza final
- concentrar logica em `modules/`
- documentar inputs e outputs
- nunca versionar segredos reais
- para entrypoints Kubernetes do `homelab`, selecionar explicitamente o perfil correto no shell com `use_homelab`
- para `clusters/ai-lab/foundation`, usar autenticacao Google valida e nao depender de kubeconfig
- validar o perfil ativo com `kctx_status` antes de operacoes sensiveis no cluster `homelab`

## Ordem recomendada
1. aplicar `clusters/homelab/bootstrap`
2. aplicar `clusters/homelab/dev`
3. aplicar `clusters/homelab/prd`

Para o `ai-lab`, nesta fase executar apenas `clusters/ai-lab/foundation`. O bootstrap do cluster fica para depois da instalacao futura do K3s.

## Execucao remota (laptop administrador)
O Terraform pode ser executado no laptop administrador. Nao e necessario abrir SSH no host apenas para rodar `terraform`.

Pre-condicoes:
- Terraform instalado no laptop
- para `clusters/homelab/*`: kubectl, helm e kubeconfig administrativo validos
- para `clusters/ai-lab/foundation`: autenticacao Google valida no provider

Pre-condicao obrigatoria de perfil:
- `use_homelab` para `terraform/clusters/homelab/*`
- `kctx_status` para verificacao explicita antes de `plan` ou `apply` no `homelab`

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
- `pathexpand(var.kubeconfig_path)` nos providers para resolucao correta de `~`

Isso evita discrepancia entre o kubeconfig ativo no shell e o kubeconfig lido pelo Terraform nos entrypoints que de fato falam com Kubernetes.

Observacao operacional importante:
- a selecao de perfil via `use_homelab` e obrigatoria mesmo quando o arquivo `terraform.tfvars` ja aponta para um kubeconfig especifico
- para a fundacao do `ai-lab`, a protecao operacional passa a ser revisar `project_id`, `admin_source_ranges` e a autenticacao Google antes do `plan`

### Baseline de tuning do Argo CD
O modulo `modules/argocd-bootstrap` passou a aplicar baseline de estabilidade/performance para homelab:

- requests/limits para componentes principais
- `timeout.reconciliation` com jitter
- `notifications` e `dex` desabilitados por padrao
- variavel `argocd_helm_values_override` para customizacao por ambiente