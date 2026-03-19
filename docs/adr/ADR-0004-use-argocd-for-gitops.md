# ADR-0004: Use Argo CD for GitOps

## Status
Accepted

## Context
O laboratório terá deploy declarativo e operação multi-ambiente.

## Decision
Utilizar Argo CD como ferramenta principal de GitOps, mantida em repositório separado.

## Consequences
### Positivas
- reconciliação declarativa
- boa visibilidade operacional
- suporte a múltiplos ambientes

### Negativas
- necessidade de manter um repositório GitOps separado e organizado

## Alternatives Considered
- deploy manual
- outras soluções de GitOps