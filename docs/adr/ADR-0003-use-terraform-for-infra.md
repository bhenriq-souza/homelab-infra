# ADR-0003: Use Terraform for Infrastructure

## Status
Accepted

## Context
A infraestrutura do laboratório precisa ser reproduzível, versionada e compatível com automação.

## Decision
Utilizar Terraform como ferramenta principal de infraestrutura como código.

## Consequences
### Positivas
- declaratividade
- versionamento
- reprodutibilidade
- integração com CI

### Negativas
- necessidade de cuidado com state, módulos e variáveis sensíveis

## Alternatives Considered
- provisionamento manual
- scripts ad hoc
- outras ferramentas de IaC