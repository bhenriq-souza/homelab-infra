# Terraform

Este diretório contém a infraestrutura como código do laboratório.

## Estrutura
- `environments/`: pontos de entrada por ambiente
- `modules/`: módulos reutilizáveis
- `scripts/`: comandos utilitários
- `policies/`: políticas e anotações futuras

## Regras
- manter `environments/` simples
- concentrar lógica em `modules/`
- documentar inputs e outputs
- nunca versionar segredos reais