# Exposure Matrix

## Objetivo
Registrar quais serviços podem ser acessados, por quem e por qual caminho.

| Serviço | Ambiente | Tipo de acesso | Origem permitida | Observações |
|---|---|---|---|---|
| SSH homelab | LAN local | privado | laptop admin, AI Lab | chave obrigatória; alias `homelab` no `~/.ssh/config` do AI Lab |
| Grafana | homelab | privado | operador | acesso via port-forward ou LAN; definir estratégia de autenticação |
| Loki | homelab | privado | operador/plataforma | acesso via gateway HTTP |
| Argo CD | homelab | privado | operador | detalhar no repo GitOps |
| API Kubernetes homelab | LAN local | privado | laptop admin, AI Lab | via `~/.kube/config-homelab.yaml`; porta `6443` não exposta para internet |
| PostgreSQL | homelab | privado interno | workloads do cluster + laptop admin + AI Lab na LAN | via Traefik TCP (`postgres.dev.homelab.local:5432`) com `loadBalancerSourceRanges` em `192.168.15.0/24` |
| Artifact Registry | GCP | público autenticado | GitHub Actions (WIF), cluster homelab (imagePullSecret via ESO) | sem VM de AI Lab na GCP |
| SSH ai-lab VM (GCP) | — | descontinuado | — | infraestrutura destruída; ver ADR-0007 |
| API Kubernetes ai-lab | — | não exposto | — | K3s no AI Lab ainda não instalado; porta `6443` para uso futuro na LAN |
