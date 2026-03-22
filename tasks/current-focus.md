# Current Focus

## Objetivo atual
Preparar a instalação inicial do cluster local K3s no mini PC já validado, definindo a estratégia de instalação e os parâmetros mínimos de rede do cluster.

## Escopo
- atualizar `docs/backlog/phase-03-k3s.md`
- atualizar `docs/operations/bootstrap-checklist.md` apenas se necessário
- atualizar `docs/network/ip-plan.md`
- atualizar `docs/operations/host-setup.md` apenas se necessário para registrar dependências do cluster

## Resultado esperado
- fase 03 detalhada e executável
- proposta inicial para Pod CIDR e Service CIDR sem conflito com a LAN
- decisão documentada sobre instalação K3s single-node
- estratégia inicial documentada para ingress embutido ou desabilitado

## Fora de escopo
- observabilidade
- Argo CD
- Terraform
- conectividade híbrida implementada
- instalação de aplicações no cluster

## Critérios de aceite
- a instalação inicial do K3s está documentada de forma clara
- os ranges básicos do cluster estão definidos ou propostos
- dependências e decisões pendentes estão explícitas