# Scripts Terraform

Scripts utilitarios para operacao local do bootstrap.

## bootstrap-order.sh
Executa `terraform init/plan/apply` na ordem recomendada:
1. `environments/shared`
2. `environments/dev`
3. `environments/prd`

O script usa as credenciais do kubeconfig local e nao gerencia estado remoto nesta fase.
