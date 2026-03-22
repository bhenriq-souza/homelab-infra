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

## Responsabilidades
- Terraform: bootstrap/foundation e instalacao inicial do Argo CD
- `gitops/`: estado desejado reconciliado continuamente pelo Argo CD