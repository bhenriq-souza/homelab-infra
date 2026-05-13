# Hybrid Connectivity

## Objetivo
Documentar a topologia de conectividade entre os ambientes do laboratório e definir a evolução para fases futuras.

## Estado atual

### Topologia LAN local
- `hlb-beelink01` (homelab server): `192.168.15.97`
- AI Lab (workstation Ubuntu): `192.168.15.103`
- Laptop admin: DHCP dinâmico
- Todos na mesma LAN `192.168.15.0/24`

O acesso do AI Lab ao cluster K3s do homelab é direto via LAN — sem VPN, sem túnel.

### Conectividade com GCP
- sem VPC ou VM do `ai-lab` na GCP (ver ADR-0007)
- a GCP é acessada pelo laptop admin e pelo AI Lab apenas via internet pública para CI/CD (GitHub Actions, Artifact Registry)
- sem necessidade de conectividade privada híbrida nesta fase

## Plano evolutivo por fases

### Fase futura 1 — cluster K3s no AI Lab
Objetivo:
- instalar K3s no AI Lab e bootstrapar Argo CD
- o `ai-lab` já está na mesma LAN que o homelab, portanto sem necessidade de VPN

Escopo esperado:
- kubeconfig do AI Lab em `~/.kube/config-ai-lab.yaml`
- ativação de `clusters/ai-lab` no repositório GitOps como cluster gerenciado
- função `use_ailab` já presente no `~/.zshrc` do AI Lab

### Fase futura 2 — conectividade híbrida com cloud
Objetivo:
- habilitar comunicação privada entre on-prem e GCP para testes híbridos reais
- relevante apenas se um recurso cloud (VM, banco gerenciado etc.) for adicionado à topologia

Escopo esperado:
- VPN ou Cloud Interconnect entre LAN e GCP VPC
- rotas explícitas entre blocos on-prem e cloud

## Princípio importante
- fleet (gestão de clusters) não substitui conectividade de rede
- mesmo com fleet, comunicação entre redes depende de desenho de conectividade, rotas e políticas

## Dependências para fase futura 2
- definição do modelo de conectividade privada (VPN, túnel ou Cloud Interconnect)
- CIDR da VPC cloud sem sobreposição com LAN e clusters locais
- estratégia de DNS para recursos híbridos

## Cuidados de arquitetura e operação
- CIDR: evitar sobreposição entre LAN, clusters locais e rede cloud
- rotas: garantir que o caminho entre redes seja explícito, previsível e auditável
- DNS: separar resolução administrativa interna de nomes públicos quando necessário
- exposição de serviços: priorizar acesso privado para administração

## Fora de escopo desta fase
- VPN ou site-to-site com GCP
- novos recursos de compute na GCP para o `ai-lab`
