# IP Plan

## Status
- este documento inicia o planejamento da LAN local
- valores ainda não definidos devem permanecer como placeholder
- preencher antes de avançar para a fase de conectividade híbrida
- reserva DHCP do mini PC concluída no roteador

## LAN local
- nome da rede local: `homelab`
- CIDR: `192.168.15.0/24`
- gateway: `192.168.15.1`
- DNS primário entregue por DHCP: `192.168.15.1`
- DNS secundário entregue por DHCP: `n/a (uso padrão do roteador/operadora)`
- faixa DHCP dinâmica do roteador: `192.168.15.2-192.168.15.200`
- política de IP estável do mini PC: `DHCP reservado`
- hostname do mini PC: `hlb-beelink01`
- interface principal do mini PC: `ethernet`
- MAC da interface principal: `78:55:36:05:22:CA`
- IP reservado do mini PC: `192.168.15.97`
- origem da reserva: `roteador Vivo MitraStar`

### Validações mínimas da LAN
- laptop alcança o mini PC por SSH no IP reservado
- não há conflito entre IP reservado e faixa dinâmica do DHCP
- gateway responde a partir do mini PC
- IP reservado permanece estável após reboot do mini PC

### Inventário de endpoints locais (preencher)
- laptop administrativo (Windows 11 + WSL): `DHCP dinâmico (sem reserva)`
- mini PC host principal: `192.168.15.97`
- roteador/gateway: `192.168.15.1`

### Notas de decisão
- o nome `homelab` é um rótulo de documentação para identificar a LAN atual
- não é necessário criar uma LAN separada no roteador nesta fase
- para reduzir risco operacional, o IP reservado do mini PC foi mantido igual ao IP atual observado

## Estratégia de DNS (intenção por fases)
- fase atual (concluindo baseline): manter DNS padrão entregue pelo roteador/operadora
- próxima etapa após esta fase inicial: migrar para DNS público no roteador (Cloudflare/Google/Quad9)
- etapa futura de evolução: avaliar DNS local com Pi-hole ou AdGuard Home

### Critérios para avançar a estratégia de DNS
- somente alterar DNS após estabilidade do acesso SSH ao mini PC
- registrar qualquer mudança de DNS neste documento antes da aplicação
- validar navegação e resolução de nomes no laptop e no mini PC após a mudança

## Cluster local
- pod CIDR: `<k3s-pod-cidr-futuro>`
- service CIDR: `<k3s-service-cidr-futuro>`
- ingress hostname/IP: `<ingress-futuro>`
- status: `fora do escopo da fase atual`

## GCP
- VPC CIDR: `<gcp-vpc-cidr-futuro>`
- subnet principal: `<gcp-subnet-futura>`
- IPs reservados relevantes: `<reservas-futuras>`
- status: `conectividade híbrida será tratada em fase posterior`

## Regras
- não permitir sobreposição entre LAN, cluster local e cloud
- qualquer alteração deve ser documentada antes da implementação
- não promover conectividade híbrida antes da LAN local estar estável