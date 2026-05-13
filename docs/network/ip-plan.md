# IP Plan

## Objetivo
- consolidar a LAN local como bloco real de endereçamento
- registrar o estado atual validado de todos os nós da LAN
- propor ranges do cluster local sem conflito com a LAN
- manter placeholders apenas para blocos ainda não definidos

## LAN local (estado atual)

### Bloco real de endereçamento
- nome lógico da LAN: `homelab`
- CIDR da LAN: `192.168.15.0/24`
- gateway: `192.168.15.1`
- faixa DHCP do roteador: `192.168.15.2-192.168.15.200`

### Inventário de endpoints locais

| Hostname | Papel | IP | Tipo |
|---|---|---|---|
| `hlb-beelink01` | Homelab server — host K3s | `192.168.15.97` | DHCP reservado |
| AI Lab (workstation Ubuntu) | Dev environment + inferência LLM (RTX 5070, Ryzen 9 7900X, 64 GB DDR5) | `192.168.15.103` | DHCP reservado |
| Laptop admin (Windows 11 + WSL) | Administração principal | DHCP dinâmico | sem reserva |
| Roteador/gateway | MitraStar GPT-2742GX4X5v6 | `192.168.15.1` | fixo |

### Metadados operacionais
- política de IP estável do mini PC: DHCP reservado
- hostname do mini PC: `hlb-beelink01`
- MAC do mini PC: `78:55:36:05:22:CA`
- origem das reservas: roteador Vivo MitraStar
- acesso administrativo atual: SSH via LAN para ambos os nós

### Observações relevantes
- mini PC, AI Lab e laptop estão na mesma LAN local
- não há necessidade de exposição pública para acesso administrativo
- o objetivo é estabilidade de acesso administrativo local
- qualquer mudança de IP/DHCP deve ser registrada aqui antes da aplicação

### Validações mínimas da LAN
- laptop e AI Lab alcançam o mini PC por SSH no IP reservado
- não há conflito entre IPs reservados e faixa dinâmica do DHCP
- gateway responde a partir do mini PC
- IPs reservados permanecem estáveis após reboot

## Estratégia de DNS (planejamento)
- fase atual: manter DNS padrão entregue pelo roteador/operadora
- fase futura: avaliar DNS público e/ou DNS local dedicado
- status: `não alterar agora; manter como decisão futura`

## Cluster local (estado atual)
- pod CIDR: `10.42.0.0/16`
- service CIDR: `10.43.0.0/16`
- ingress hostname/IP final: `<ingress-futuro>`

### Validação de não-conflito (estado atual)
- LAN local: `192.168.15.0/24`
- Pod CIDR local: `10.42.0.0/16`
- Service CIDR local: `10.43.0.0/16`
- resultado: `sem sobreposição entre LAN e rede interna do cluster`

## GCP (CI/CD — estado atual)
- a GCP não possui mais VM ou rede para o `ai-lab` (ver ADR-0007)
- recursos GCP ativos: Artifact Registry, WIF, Secret Manager (sem VPC/subnet dedicada ao ai-lab)
- status: `infraestrutura de VM do ai-lab destruída; GCP permanece apenas para CI/CD`

## Regras
- não permitir sobreposição entre LAN, cluster local e cloud
- qualquer alteração deve ser documentada antes da implementação
- ranges de cloud devem permanecer sem conflito com LAN e cluster local
