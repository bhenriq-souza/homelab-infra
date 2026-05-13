# Phase 08 - Hybrid Fleet

## Objetivo
Consolidar a base para operação com múltiplos clusters, com o `ai-lab` como segundo cluster gerenciado — agora na workstation Ubuntu local, na mesma LAN que o homelab.

## Decisão arquitetural

O `ai-lab` é a workstation Ubuntu local (`192.168.15.103`), não uma VM na GCP — ver ADR-0007.

A conectividade entre `ai-lab` e o cluster `homelab` é direta via LAN, sem VPN. O scaffold GitOps em `clusters/ai-lab` já está versionado no repositório `homelab-gitops` aguardando a instalação do K3s.

## Macrotarefas

### Concluído
- repositório dedicado `homelab-gitops` criado
- cluster atual migrado para `clusters/homelab`
- estrutura inicial de `clusters/ai-lab` criada no repositório GitOps
- naming `cluster-first` consolidado para `homelab` e `ai-lab`
- acesso do AI Lab ao cluster `homelab`: SSH (`ssh homelab`) + kubeconfig (`~/.kube/config-homelab.yaml`) operacionais
- funções `use_homelab` / `use_ailab` / `kctx_status` no `~/.zshrc` do AI Lab

### Pendente — Fase 9
- definir reserva DHCP para o AI Lab no roteador (IP `192.168.15.103` já em uso, formalizar a reserva)
- instalar K3s no AI Lab
- copiar e ajustar kubeconfig do AI Lab para `~/.kube/config-ai-lab.yaml` no laptop admin
- bootstrapar Argo CD no cluster `ai-lab`
- ativar `clusters/ai-lab` no repositório GitOps como cluster gerenciado ativo
- validar gestão multi-cluster (homelab + ai-lab) via Argo CD

## Diretriz arquitetural
- o cluster `homelab` permanece como referência operacional principal
- o `ai-lab` é o segundo cluster, ainda não bootstrapado
- ambos os clusters estão na LAN `192.168.15.0/24` — sem necessidade de VPN para comunicação entre eles
- a estrutura GitOps em `clusters/ai-lab` permanece como scaffold até a instalação do K3s

## Critérios de aceite desta fase (revisados)
- caminho arquitetural consolidado: `ai-lab` local (ADR-0007 aceita)
- acesso operacional do AI Lab ao cluster homelab validado
- backlog da Fase 9 pronto para iniciar instalação do K3s no AI Lab
