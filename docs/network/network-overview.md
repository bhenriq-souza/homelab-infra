# Network Overview

## Objetivo
Definir a conectividade entre:
- laptop do operador
- mini PC on-prem
- cluster local
- VPC na GCP
- componentes administrativos e operacionais

## Blocos principais
- LAN local
- rede do cluster local
- VPC cloud
- conectividade híbrida
- exposição controlada de serviços

## Princípios
- evitar sobreposição de CIDRs
- preferir acesso privado para componentes administrativos
- documentar toda exposição de portas
- manter desenho simples nas fases iniciais