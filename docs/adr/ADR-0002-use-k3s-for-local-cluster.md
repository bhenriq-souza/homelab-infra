# ADR-0002: Use K3s for Local Cluster

## Status
Accepted

## Context
O cluster local será executado em hardware enxuto, com foco em homelab, experimentação e simplicidade operacional.

## Decision
Utilizar K3s como distribuição Kubernetes local.

## Consequences
### Positivas
- menor footprint
- instalação simples
- boa aderência a homelab
- evolução incremental facilitada

### Negativas
- algumas diferenças em relação a cenários baseados em kubeadm ou distribuições maiores

## Alternatives Considered
- kubeadm
- MicroK8s
- k3d