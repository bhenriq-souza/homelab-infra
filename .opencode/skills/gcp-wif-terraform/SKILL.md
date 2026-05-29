---
name: gcp-wif-terraform
description: Use ONLY when working on GCP Workload Identity Federation, GitHub Actions OIDC, Artifact Registry, GCP service accounts, IAM bindings, Secret Manager references, or CI/CD Terraform in homelab-infra.
---

# GCP WIF Terraform

Use this skill only for GCP CI/CD identity and registry infrastructure in `homelab-infra`.

## Required Context

Before changing related files, read:

- `AGENTS.md`
- `docs/adr/ADR-0006-cicd-with-github-actions-and-artifact-registry.md`
- `docs/architecture/target-architecture.md`
- `docs/architecture/naming-conventions.md`
- `tasks/current-focus.md`
- The affected Terraform root and modules, especially Artifact Registry, GitHub WIF, IAM, service account, and Secret Manager references.

## ADR-0006 Decisions To Preserve

- Artifact Registry repository name: `homelab-apps`.
- GitHub Actions authenticates to GCP via OIDC/WIF, not static keys.
- GitHub WIF uses a dedicated pool/provider separate from the K3s ESO fallback model.
- Image pull secrets use the ESO + GCP Secret Manager fallback model.
- The reusable workflow is centralized in `homelab-gitops`.
- App repositories should contain only minimal caller workflows.
- Branch intent remains `develop` to `dev` and `main` to `prd` unless a new ADR changes it.

## IAM And Secret Rules

- Treat IAM changes as approval-sensitive.
- Avoid broad IAM roles; grant the narrowest role needed for the documented action.
- Keep service accounts purpose-specific.
- Avoid wildcard repository, branch, or principal conditions unless explicitly justified.
- Use placeholders in docs and examples for secret values and provider identifiers.

## Validation

- Inspect the affected Terraform root before running validation.
- Prefer `terraform fmt -check` and `terraform validate` for changed roots when applicable.
- Review GitHub workflow YAML changes for permissions, OIDC configuration, secret references, and trigger scope.

## Forbidden Actions

- Never print or commit credentials, service account keys, PATs, WIF provider values, Secret Manager payloads, or generated dockerconfigjson content.
- Do not run GCP write commands unless the user explicitly requests them.
- Do not run Terraform write/state commands unless the user explicitly requests them.
- Do not move reusable workflow implementation details from `homelab-gitops` into this repository.
