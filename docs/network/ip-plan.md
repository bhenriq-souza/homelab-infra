# IP Plan

## Objetivo
- consolidar a LAN local como primeiro bloco real do plano de endereçamento
- registrar o estado atual já validado (host on-prem + SSH + DHCP reservado)
- manter placeholders apenas para blocos ainda não definidos (cluster e cloud)

## LAN local (estado atual)

### Bloco real de enderecamento
- nome logico da LAN: `homelab`
- CIDR da LAN: `192.168.15.0/24`
- gateway: `192.168.15.1`
- faixa DHCP do roteador: `192.168.15.2-192.168.15.200`
- IP reservado do mini PC: `192.168.15.97`

### Metadados operacionais
- politica de IP estavel do mini PC: `DHCP reservado`
- hostname do mini PC: `hlb-beelink01`
- origem da reserva: `roteador Vivo MitraStar`
- acesso administrativo atual: `SSH via LAN`

### Observacoes relevantes
- mini PC e laptop estao na mesma LAN local
- nao ha necessidade de exposicao publica nesta etapa
- o objetivo imediato e estabilidade de acesso administrativo local
- qualquer mudanca de IP/DHCP deve ser registrada aqui antes da aplicacao

### Validações mínimas da LAN
- laptop alcança o mini PC por SSH no IP reservado
- não há conflito entre IP reservado e faixa dinâmica do DHCP
- gateway responde a partir do mini PC
- IP reservado permanece estável após reboot do mini PC

### Inventario de endpoints locais
- laptop administrativo (Windows 11 + WSL): `DHCP dinamico (sem reserva)`
- mini PC host principal: `192.168.15.97`
- roteador/gateway: `192.168.15.1`

### Notas de decisão
- o nome `homelab` é um rótulo de documentação para identificar a LAN atual
- não é necessário criar uma LAN separada no roteador nesta fase
- para reduzir risco operacional, o IP reservado do mini PC foi mantido igual ao IP atual observado

## Estrategia de DNS (planejamento)
- fase atual: manter DNS padrao entregue pelo roteador/operadora
- fase futura: avaliar DNS publico e/ou DNS local dedicado
- status: `nao alterar agora; manter como decisao futura`

### Criterios para evoluir DNS
- somente alterar DNS apos estabilidade comprovada do acesso SSH
- registrar qualquer mudanca de DNS neste documento antes da aplicacao
- validar navegacao e resolucao de nomes no laptop e no mini PC apos a mudanca

## Cluster local (definir depois)
- pod CIDR: `<k3s-pod-cidr-futuro>`
- service CIDR: `<k3s-service-cidr-futuro>`
- ingress hostname/IP: `<ingress-futuro>`
- status: `pendente; fora do escopo desta etapa`

## Cloud (GCP - definir depois)
- VPC CIDR: `<gcp-vpc-cidr-futuro>`
- subnet principal: `<gcp-subnet-futura>`
- IPs reservados relevantes: `<reservas-futuras>`
- status: `pendente; conectividade hibrida sera tratada em fase posterior`

## Regras
- nao permitir sobreposicao entre LAN, cluster local e cloud
- qualquer alteracao deve ser documentada antes da implementacao
- ranges de cluster local e cloud devem ser definidos depois, sem conflito com a LAN atual
- nao promover conectividade hibrida antes da LAN local estar estavel