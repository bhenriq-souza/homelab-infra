# Network Overview

## Objetivo
Definir a conectividade entre:
- laptop do operador
- mini PC on-prem
- cluster local
- VPC na GCP
- componentes administrativos e operacionais

## Sequencia por fases
1. fase atual: consolidar LAN local para operacao do host e acesso administrativo via SSH
2. fase futura 1: habilitar conectividade privada simples on-prem + cloud para administracao e testes
3. fase futura 2: evoluir para conectividade hibrida mais proxima de site-to-site

## Estado atual da conectividade
- mini PC conectado por cabo ethernet na LAN doméstica
- acesso administrativo atual é somente SSH
- laptop administrativo em Windows 11 com Ubuntu no WSL
- requisito imediato: acesso estável do laptop ao host `hlb-beelink01` na rede local
- conectividade híbrida (VPN/túnel/peering) ainda não iniciada

## Evolucao futura (planejada)
- conectividade privada com GCP sera tratada apenas em fases futuras
- nao ha implementacao de conectividade hibrida nesta etapa
- fleet/multi-cluster nao substitui conectividade de rede entre ambientes

## Primeira meta de rede (fase atual)
- o mini PC deve ser acessível do laptop pela LAN usando o IP reservado
- resolução por hostname local é opcional nesta etapa e não será requisito de aceite agora
- nenhuma dependência de Kubernetes para concluir esta meta

## Resolução por hostname (planejamento)
- objetivo futuro: facilitar operação usando nome lógico do host na LAN
- decisão atual: não implementar nem exigir nesta fase
- gatilho para adoção: quando houver necessidade de operar múltiplos serviços por nome

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

## Escopo de exposição nesta etapa
- manter SSH disponível apenas na LAN local
- não publicar serviços administrativos para internet
- preparar documentação para exposição web futura em fase específica