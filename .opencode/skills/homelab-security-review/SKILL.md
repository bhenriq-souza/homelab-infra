---
name: homelab-security-review
description: Use when work touches homelab security posture, network exposure, secrets, IAM, External Secrets, Kubernetes access assumptions, dashboards, public endpoints, host hardening, backup and restore risk, or operational safety.
---

# Homelab Security Review

Use this skill when a change affects security posture or operational safety in `homelab-infra`.

## Trigger Areas

Use for work involving:

- Network exposure, ingress, public endpoints, LAN assumptions, or port access.
- Secrets, Secret Manager references, External Secrets, image pull secrets, service account keys, PATs, kubeconfigs, or tokens.
- IAM roles, service accounts, WIF bindings, and GitHub Actions identity.
- Kubernetes access assumptions, ArgoCD access assumptions, dashboards, Grafana, Prometheus, Loki, or observability exposure.
- Host hardening, SSH, backup/restore risk, PostgreSQL operational risk, or rollback safety.

## Security Principles

- Prefer least privilege and minimal exposure.
- Keep dashboards and observability access conservative for the single-node homelab.
- Prefer LAN/internal access and documented operator workflows unless an ADR allows broader exposure.
- Keep security guidance aligned with current homelab constraints: local LAN access, single-node K3s, and GitOps separation.
- Preserve the separation between `homelab-infra` planning/IaC and `homelab-gitops` desired state.

## Approval-Sensitive Changes

Treat these as requiring explicit approval before execution:

- Secret writes or secret payload changes.
- IAM role or binding changes.
- Terraform write/state operations.
- Kubernetes write operations.
- ArgoCD write or sync operations.
- Public endpoint exposure or dashboard exposure changes.

## Safe Handling

- Never commit plaintext secrets.
- Never print credentials, kubeconfigs, service account keys, PATs, WIF provider values, or Secret Manager payloads.
- Prefer safe examples and placeholders.
- Document risks and rollback considerations for security-sensitive changes.
- Check whether an ADR, architecture doc, or backlog item needs updating after a security-significant change.
