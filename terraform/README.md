# Terraform

Este diretorio contem a infraestrutura como codigo de bootstrap/foundation do laboratorio.

## Estrutura
- `environments/`: entrypoints por ambiente logico (`shared`, `dev`, `prd`)
- `modules/`: modulos reutilizaveis
- `scripts/`: comandos utilitarios
- `policies/`: politicas e anotacoes futuras

## Modelo desta fase
- `shared`: recursos cluster-wide, incluindo instalacao do Argo CD no namespace `argocd`
- `dev`: namespaces e base do ambiente logico `dev` no mesmo cluster
- `prd`: namespaces e base do ambiente logico `prd` no mesmo cluster

## Regras
- manter `environments/` simples
- concentrar logica em `modules/`
- documentar inputs e outputs
- nunca versionar segredos reais

## Ordem recomendada
1. aplicar `environments/shared`
2. aplicar `environments/dev`
3. aplicar `environments/prd`

## Execucao remota (laptop administrador)
O bootstrap Terraform pode ser executado no laptop administrador. Nao e necessario abrir SSH no host apenas para rodar `terraform`.

Pre-condicoes:
- Terraform, kubectl e helm instalados no laptop
- conectividade de rede do laptop ate a API do cluster K3s
- kubeconfig administrativo valido no laptop
- contexto kubeconfig correto para o cluster alvo

Checklist rapido:
1. `kubectl config current-context --kubeconfig <kubeconfig>`
2. `kubectl cluster-info --kubeconfig <kubeconfig>`
3. `kubectl get nodes --kubeconfig <kubeconfig>`
4. `terraform -chdir=terraform/environments/shared init -upgrade`
5. `terraform -chdir=terraform/environments/shared providers`

O script `scripts/bootstrap-order.sh` aceita variaveis de ambiente para selecionar cluster/contexto sem alterar `terraform.tfvars`:
- `KUBECONFIG`: caminho do arquivo kubeconfig
- `KUBE_CONTEXT`: contexto kubeconfig (opcional)

Exemplo:

```bash
KUBECONFIG=/home/<usuario>/.kube/config-homelab.yaml \
KUBE_CONTEXT=default \
./terraform/scripts/bootstrap-order.sh
```

## Responsabilidades
- Terraform: bootstrap/foundation e instalacao inicial do Argo CD
- `gitops/`: estado desejado reconciliado continuamente pelo Argo CD

## Notas operacionais recentes

### Padrao de kubeconfig por ambiente
Para evitar erro de provider (`context "default" does not exist`), os ambientes Terraform foram padronizados para usar:

- `kubeconfig_path = "~/.kube/config-homelab.yaml"` nos `terraform.tfvars`
- `pathexpand(var.kubeconfig_path)` nos providers para resolucao correta de `~`

Isso evita discrepancia entre o kubeconfig ativo no shell e o kubeconfig lido pelo Terraform.

### Baseline de tuning do Argo CD
O modulo `modules/argocd-bootstrap` passou a aplicar baseline de estabilidade/performance para homelab:

- requests/limits para componentes principais
- `timeout.reconciliation` com jitter
- `notifications` e `dex` desabilitados por padrao
- variavel `argocd_helm_values_override` para customizacao por ambiente