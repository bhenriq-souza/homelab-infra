# Current Focus

## Objetivo atual
Consolidar a documentação de rede do laboratório com base no host já validado, no acesso SSH funcional e no DHCP reservado para o mini PC.

## Escopo
- atualizar `docs/network/ip-plan.md`
- atualizar `docs/network/hybrid-connectivity.md`
- atualizar `docs/network/network-overview.md` apenas se necessário para consistência

## Resultado esperado
- plano de IP com os dados reais já conhecidos da LAN local
- estratégia de conectividade híbrida documentada em fases
- separação clara entre rede local atual e evolução futura para integração com GCP

## Fora de escopo
- instalação de K3s
- criação de Terraform
- configuração de VPN real
- configuração da VPC na GCP
- alterações em ADRs

## Critérios de aceite
- `ip-plan.md` reflete o estado atual conhecido da LAN
- `hybrid-connectivity.md` descreve a evolução da conectividade híbrida em etapas
- decisões pendentes ficam explícitas