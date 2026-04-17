# Exposure Matrix

## Objetivo
Registrar quais serviços podem ser acessados, por quem e por qual caminho.

| Serviço | Ambiente | Tipo de acesso | Origem permitida | Observações |
|---|---|---|---|---|
| SSH host | local | privado | laptop/admin | chave obrigatória |
| SSH ai-lab VM base | gcp-lab | publico restrito | CIDRs administrativos autorizados | IP publico estatico com regra de firewall dedicada |
| Grafana | local | privado | operador | definir estratégia de autenticação |
| Loki | local | privado | operador/plataforma | acesso via gateway HTTP |
| Argo CD | local | privado | operador | detalhar no repo GitOps; ai-lab ainda nao tem bootstrap nesta fase |
| API Kubernetes ai-lab | gcp-lab | nao exposto nesta fase | n/a | liberacao da porta `6443` fica para a fase de instalacao do K3s |
| PostgreSQL | local | privado interno | workloads autorizados no cluster e laptop admin na LAN | via Traefik TCP (`postgres.dev.homelab.local:5432`) com `loadBalancerSourceRanges` em `192.168.15.0/24` e sem exposição para internet |