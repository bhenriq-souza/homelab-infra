# ADR-0007: Host AI Lab on Local Ubuntu Workstation

## Status
Accepted — supersede ADR-0005

## Context
A abordagem anterior (ADR-0005) definia hospedar o `ai-lab` em uma VM na GCP. Após múltiplas tentativas de provisionar a VM com GPU (T4) em diversas regiões e zonas do GCP, o bloqueio observado foi de capacidade real do Compute Engine — não de quota nem de sintaxe do Terraform. A infraestrutura GCP foi destruída ao final das tentativas para evitar custos recorrentes.

Em paralelo, o `ai-lab` passou a ser operado diretamente na workstation Ubuntu física já existente na mesma LAN do homelab. A máquina tem hardware dedicado, está na LAN `192.168.15.0/24` e já está operacional como ambiente de desenvolvimento com acesso ao cluster K3s do homelab.

### Hardware do AI Lab

| Componente | Especificação |
|---|---|
| CPU | AMD Ryzen 9 7900X — 4.7GHz base / 5.6GHz Turbo, 12 cores / 24 threads, AM5 |
| GPU | Asus NVIDIA GeForce RTX 5070 ATS OC — 12 GB GDDR7, DLSS, Ray Tracing |
| RAM | 64 GB DDR5 5600 MHz (2x XPG Lancer Blade 32 GB) |
| Armazenamento | 2x Adata Legend 860 1 TB M.2 NVMe PCIe (leitura 6000 MB/s, gravação 4000 MB/s) |
| Placa-mãe | MSI PRO B650M-P — Chipset B650, AM5, M-ATX, DDR5 |
| Fonte | Corsair RM850e 850W — Cybenetics Gold, PCIe 5.1, Full Modular |
| Cooler | Gamemax IceBurg 360N2 Digital BK — ARGB, 360mm |
| OS | Ubuntu (dual boot com Windows — SSDs separados por SO) |

## Decision
- o `ai-lab` é a workstation Ubuntu local, não uma VM na GCP
- IP fixo por reserva DHCP: `192.168.15.103`
- hostname: a definir (máquina local do operador)
- acesso ao cluster homelab: via kubeconfig em `~/.kube/config-homelab.yaml` e SSH por alias `homelab`
- GPU: hardware local da workstation, sem dependência de cloud
- o Terraform em `terraform/clusters/ai-lab/foundation` é mantido como referência histórica, mas não representa infraestrutura ativa
- o scaffold GitOps em `clusters/ai-lab` no repositório `homelab-gitops` permanece versionado para uso futuro quando o cluster K3s do `ai-lab` for instalado
- a GCP permanece em uso apenas para CI/CD: Artifact Registry, WIF e Secret Manager

## Consequences

### Positivas
- elimina custo recorrente de VM na GCP para o `ai-lab`
- elimina dependência de disponibilidade de GPU no Compute Engine
- o `ai-lab` está na mesma LAN que o homelab, sem necessidade de VPN ou conectividade híbrida para acesso ao cluster
- acesso administrativo equivalente ao do laptop admin: SSH por chave + kubeconfig LAN
- GPU local disponível imediatamente para cargas de trabalho de IA (Ollama e afins)

### Negativas
- o `ai-lab` deixa de ser um ambiente cloud para testes híbridos reais
- a topologia híbrida on-prem + cloud perde um nó no lado cloud para experimentação
- conectividade híbrida via GCP deixa de ser validada nesta fase

## Alternatives Considered
- continuar tentando provisionar VM com GPU na GCP em outras regiões ou com outro tipo de GPU
- usar `ai-lab` sem GPU na GCP (máquina puramente de propósito geral)
- usar GCP Cloud Run ou serviços gerenciados em vez de VM dedicada
