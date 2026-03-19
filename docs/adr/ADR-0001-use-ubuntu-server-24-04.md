# ADR-0001: Use Ubuntu Server 24.04 LTS

## Status
Accepted

## Context
O host principal do laboratório será um mini PC com foco em operação simples, boa documentação, compatibilidade ampla e familiaridade do operador.

## Decision
Utilizar Ubuntu Server 24.04 LTS como sistema operacional base do host on-prem.

## Consequences
### Positivas
- plataforma conhecida
- suporte de longo prazo
- boa documentação
- ampla compatibilidade com ferramentas do laboratório

### Negativas
- necessidade de manter baseline de hardening e updates sob controle

## Alternatives Considered
- Debian
- Ubuntu Desktop
- outras distribuições minimalistas