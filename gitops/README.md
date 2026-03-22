# GitOps

Este diretorio contem o estado desejado do cluster reconciliado pelo Argo CD.

## Estrutura
- `bootstrap/root`: aplicacao raiz (app-of-apps).
- `apps/shared`: componentes compartilhados no cluster.
- `apps/dev`: componentes especificos do ambiente logico `dev`.
- `apps/prd`: componentes especificos do ambiente logico `prd`.

## Modelo de ambientes nesta fase
- Existe apenas um cluster K3s.
- `dev` e `prd` sao ambientes logicos segregados por namespaces.
- Recursos cluster-wide ficam em `apps/shared`.

## Ownership
- Terraform: bootstrap/foundation (instalacao do Argo CD e namespaces base).
- GitOps: estado desejado continuo de aplicacoes e configuracoes declarativas.
