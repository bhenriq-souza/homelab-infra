# Scripts Terraform

Scripts utilitarios para operacao local do bootstrap.

## bootstrap-order.sh
Executa `terraform init/plan/apply` na ordem recomendada:
1. `clusters/homelab/bootstrap`
2. `clusters/homelab/dev`
3. `clusters/homelab/prd`

O script usa as credenciais do kubeconfig local e nao gerencia estado remoto nesta fase.

Observacao:
O bootstrap de um novo cluster, como `clusters/ai-lab/bootstrap`, deve ser executado separadamente para evitar aplicar no contexto errado.
