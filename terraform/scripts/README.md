# Scripts Terraform

Scripts utilitarios para operacao local do bootstrap.

## bootstrap-order.sh
Executa `terraform init/plan/apply` na ordem recomendada:
1. `clusters/homelab/bootstrap`
2. `clusters/homelab/dev`
3. `clusters/homelab/prd`

O script usa as credenciais do kubeconfig local e nao gerencia estado remoto nesta fase.

Observacao:
A fundacao GCP do `ai-lab`, em `clusters/ai-lab/foundation`, deve ser executada separadamente, com autenticacao Google valida e sem depender de kubeconfig.
