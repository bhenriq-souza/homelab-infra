# Terraform Environments

Cada subdiretorio em `environments/` e um entrypoint de Terraform.

## Estrategia desta fase
- `shared/`: recursos compartilhados do cluster (bootstrap do Argo CD).
- `dev/`: recursos especificos do ambiente logico `dev` no mesmo cluster.
- `prd/`: recursos especificos do ambiente logico `prd` no mesmo cluster.

## Ordem recomendada de aplicacao
1. `shared`
2. `dev`
3. `prd`

Isso separa o que e cluster-wide do que e ambiente-especifico.
