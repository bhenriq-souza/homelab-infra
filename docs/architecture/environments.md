# Environments

## shared
Recursos compartilhados e fundacionais do laboratório.

Exemplos:
- APIs habilitadas no projeto GCP
- artefatos compartilhados
- configurações comuns

## homelab
Ambiente on-prem local: cluster K3s single-node no mini PC `hlb-beelink01`.

- IP: `192.168.15.97`
- LAN: `192.168.15.0/24`
- acesso administrativo: SSH por chave + kubeconfig LAN

## ai-lab
Workstation Ubuntu local do operador, na mesma LAN do homelab.

- IP: `192.168.15.103` (DHCP reservado)
- LAN: `192.168.15.0/24`
- acesso ao cluster homelab: via `~/.kube/config-homelab.yaml` + alias SSH `homelab`
- K3s no `ai-lab`: planejado para fase futura; scaffold GitOps já versionado em `homelab-gitops/clusters/ai-lab`

### Hardware

| Componente | Especificação |
|---|---|
| CPU | AMD Ryzen 9 7900X — 4.7GHz / 5.6GHz Turbo, 12c/24t, AM5 |
| GPU | Asus RTX 5070 ATS OC — 12 GB GDDR7, arquitetura Blackwell (sm_120) |
| RAM | 64 GB DDR5 5600 MHz |
| Armazenamento | 2x 1 TB NVMe M.2 PCIe — SSD 1: Ubuntu 26.04 LTS + `/home`; SSD 2: `/data` (workloads de IA) |
| Placa-mãe | MSI PRO B650M-P (B650, AM5, M-ATX) |

### Stack de IA ativo (Fase 1 — DA-014)

- **Driver NVIDIA:** 595.58.03 | CUDA 13.2 | `nvidia-container-toolkit` instalado
- **Ollama** — `http://192.168.15.103:11434` — modelo `qwen2.5:7b` na GPU
- **TEI** — `http://192.168.15.103:8080` — modelo `BAAI/bge-m3` em CPU (imagem `cpu-latest` — workaround: sem suporte GPU para Blackwell sm_120)
- **`/data`** montado via fstab (`ext4`, `defaults,noatime,nofail`, UUID fixo)
  - `/data/models/ollama` — modelos Ollama (bind mount)
  - `/data/models/tei-cache` — cache HuggingFace TEI (bind mount)
  - `/data/docker` — Docker data-root
- Artefatos do setup: `techlead-joe-infra/experiments/ai-lab/`

## gcp-lab
Ambiente cloud na GCP — exclusivo para serviços de CI/CD e gestão de artefatos.

Recursos ativos:
- Artifact Registry (`homelab-apps`) para imagens de container
- WIF pool/provider para autenticação do GitHub Actions
- Secret Manager para image pull secrets
- Service accounts dedicadas por finalidade

Recursos não ativos (infraestrutura AI Lab descontinuada):
- VPC, subnet, VM e disco do `ai-lab` foram destruídos (ver ADR-0007)
- Terraform em `terraform/clusters/ai-lab/foundation` mantido como referência histórica
