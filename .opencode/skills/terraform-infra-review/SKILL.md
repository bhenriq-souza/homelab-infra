---
name: terraform-infra-review
description: Use when reviewing Terraform or infrastructure-as-code changes in homelab-infra, including modules, environment roots, providers, variables, outputs, and repository-local validation.
---

# Terraform Infra Review

Use this skill for Terraform and infrastructure-as-code changes in `homelab-infra`.

## Required Context

Before editing or reviewing Terraform, read:

- `AGENTS.md`
- `docs/architecture/target-architecture.md`
- `docs/architecture/roadmap.md`
- `docs/architecture/naming-conventions.md`
- `docs/adr/README.md`
- Any ADR relevant to the changed Terraform, especially ADR-0006 for CI/CD and Artifact Registry work.
- `tasks/current-focus.md`
- The affected Terraform root and any modules it calls.

## Rules

- Respect accepted ADRs and current architecture docs.
- Prefer small, cohesive Terraform modules and incremental environment-specific changes.
- Keep responsibilities separate across `shared`, `dev`, `prd`, `homelab`, and future `ai-lab` work.
- Follow naming conventions; prefer kebab-case, predictable resource names, and documented abbreviations only.
- Keep module inputs and outputs minimal and explicit.
- Avoid broad refactors unless required by the requested change.
- Do not move detailed ArgoCD workload manifests into this repository; those belong in `homelab-gitops`.

## Review Workflow

1. Identify every changed Terraform root and module.
2. Read the full affected root before choosing validation.
3. Check provider configuration, backend usage, variable defaults, outputs, and module boundaries.
4. Check whether the change affects IAM, secrets, Kubernetes access, ArgoCD, or public exposure.
5. Confirm documentation or ADR impact before finalizing.

## Validation

Use read-only validation for changed roots when applicable:

- `terraform fmt -check`
- `terraform validate`

Run Terraform commands from the relevant root after inspecting it. Do not assume a single repository-wide Terraform root.

## Forbidden Actions

- Never run `terraform apply`, `terraform destroy`, `terraform import`, Terraform state mutation, or secret-modifying commands unless the user explicitly requests them.
- Never print or commit secret values, kubeconfigs, service account keys, PATs, WIF provider values, or generated credentials.
- Never broaden IAM or network exposure casually; treat those changes as approval-sensitive.
