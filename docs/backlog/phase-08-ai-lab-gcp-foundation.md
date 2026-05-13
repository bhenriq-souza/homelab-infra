# Phase 08 - AI Lab GCP Foundation

## Status
**Cancelado — ver ADR-0007**

A abordagem de hospedar o `ai-lab` na GCP foi descontinuada. A infraestrutura provisionada (VPC, subnet, VM, disco, firewall, IP estático, service account) foi destruída via `terraform destroy`. O estado Terraform ficou vazio após o rollback.

O `ai-lab` é agora a workstation Ubuntu local do operador (`192.168.15.103`), na mesma LAN que o homelab.

---

## Contexto histórico

### Objetivo original
Provisionar a infraestrutura base do `ai-lab` na GCP, mantendo a solução simples, reutilizável e preparada para receber o K3s em uma etapa posterior.

### Tentativas de provisionar VM com GPU

| Região/Zona | Shape tentado | Resultado |
|---|---|---|
| `us-central1-a/b/c/f` | `n1-standard-8 + 1x T4` | sem capacidade |
| `us-east1-b/c/d` | `n1-standard-8 + 1x T4` | sem capacidade ou rejeitado |
| `us-east4-b` | `n1-standard-8 + 1x T4` | sem capacidade |
| `europe-west1-b/c/d` | `n1-standard-8 + 1x T4` | sem capacidade |

O bloqueio foi de capacidade real do Compute Engine, não de quota nem de sintaxe do Terraform.

### Resultado operacional
- `terraform destroy` removeu 11 recursos remanescentes
- estado Terraform da foundation ficou vazio após o rollback
- Terraform em `terraform/clusters/ai-lab/foundation` mantido como referência histórica

### Validações confirmadas durante as tentativas
- quota regional de `NVIDIA_T4_GPUS` encontrada nas regiões tentadas
- egress público do cluster `homelab`: `177.76.206.120`
- o mesmo NAT público atende laptop admin e cluster homelab

---

## Referência
- ADR-0007: `docs/adr/ADR-0007-host-ai-lab-on-local-ubuntu.md`
- Backlog da fase de fleet: `docs/backlog/phase-08-hybrid-fleet.md`
