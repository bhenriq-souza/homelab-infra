# AGENTS.md - homelab-infra

## Mission

This repository is the operational entrypoint for agents working on homelab infrastructure planning and infrastructure-as-code.

It owns macro architecture, ADRs, network and security documentation, Terraform/IaC, operational planning, the infra backlog, and repository-local validation workflows for the homelab and hybrid infrastructure.

Use `AGENT_CONTEXT.md` as historical/context material only. Keep it unchanged unless the user explicitly asks to update it.

## Repository Boundaries

This repository may contain and update:

- Architecture documentation under `docs/architecture/`.
- ADRs under `docs/adr/`.
- Network, security, and operational documentation.
- Terraform modules and environment roots under `terraform/`.
- Infrastructure backlog and current planning under `tasks/` and `docs/backlog/`.
- Repository-local validation workflows.

This repository must not own:

- Frontend application code.
- Backend application code.
- Detailed ArgoCD workload manifests.
- Application business rules.

GitOps desired state belongs in `homelab-gitops`. Detailed Kubernetes workload manifests, ArgoCD application trees, Kustomize overlays, ExternalSecrets, and app deployment state should be changed there, not here.

## Mandatory Context Files

Before non-trivial work, read the relevant current files. At minimum, read:

- `README.md`
- `AGENT_CONTEXT.md`
- `docs/architecture/target-architecture.md`
- `docs/architecture/roadmap.md`
- `docs/architecture/naming-conventions.md`
- `docs/adr/README.md`
- `docs/adr/ADR-0006-cicd-with-github-actions-and-artifact-registry.md`
- `tasks/current-focus.md`

Also read any affected Terraform root, module, ADR, backlog item, or architecture document before editing it.

## Current Status Source of Truth

When documentation disagrees, treat these as authoritative in this order:

- `tasks/current-focus.md`
- `docs/architecture/target-architecture.md`
- Accepted ADRs under `docs/adr/`

Current important context:

- The K3s single-node homelab is operational.
- `homelab-gitops` is the active ArgoCD desired-state repository.
- The observability metrics/dashboard phase is completed for the current scope.
- The next active direction includes logs consolidation, PostgreSQL dev baseline, and CI/CD validation.
- ADR-0006 defines the GitHub Actions + Artifact Registry + Workload Identity Federation direction.
- The AI Lab is the local Ubuntu workstation per ADR-0007 and current-focus context, not a GCP VM.

## Architecture Rules

- Respect existing ADRs. If a change conflicts with an accepted ADR, update the decision trail before implementing the change.
- Prefer small Terraform modules and incremental changes.
- Keep Terraform roots and modules cohesive; do not introduce broad, multi-purpose modules without clear need.
- Keep environment responsibilities separate, especially `shared`, `dev`, `prd`, `homelab`, and future `ai-lab` work.
- Follow `docs/architecture/naming-conventions.md`: use predictable kebab-case names and avoid undocumented abbreviations.
- Keep GCP usage aligned with current architecture: Artifact Registry, WIF, and Secret Manager support CI/CD and secret references.
- Keep `ai-lab` aligned with ADR-0007: local workstation first; `terraform/clusters/ai-lab/foundation` is historical reference unless an ADR changes that status.

## Safety Rules

- Treat IAM changes, secret writes, Terraform writes, Kubernetes writes, ArgoCD writes, and public exposure changes as approval-sensitive.
- Prefer least privilege and minimal network exposure.
- Do not print, commit, or preserve plaintext secrets, tokens, service account keys, PATs, kubeconfigs, WIF provider values, or secret payloads.
- Use placeholders for examples involving credentials or secret values.
- Keep dashboards and observability exposure conservative for a single-node homelab; prefer LAN/internal access unless documentation explicitly allows otherwise.
- Do not modify application repositories while working from this repository.

## Validation Commands

Use conservative validation based on existing tooling only. Do not invent scripts.

For Terraform changes:

- Inspect the changed Terraform roots before choosing validation commands.
- Prefer read-only validation such as `terraform fmt -check` and `terraform validate` for affected roots when applicable.
- Run validation from the relevant Terraform root, not blindly from the repository root.
- Do not run `terraform apply`, `terraform destroy`, `terraform import`, state mutation, or secret-modifying commands unless explicitly requested.

For GitHub workflow changes:

- Review the changed YAML carefully for syntax, permissions, secret references, and trigger scope.
- Keep workflow validation limited to existing local tooling if present.

For documentation-only changes:

- Read back changed files and verify links, paths, ADR references, and repository boundaries.

## Agent Workflow

1. Read the mandatory context files and any task-specific files.
2. Identify which repository owns the requested change: `homelab-infra` for macro infra/IaC/planning, `homelab-gitops` for desired-state manifests, or an application repo for app code.
3. Check accepted ADRs before changing architecture, CI/CD, IAM, secrets, network exposure, or environment responsibilities.
4. Make the smallest cohesive change that satisfies the task.
5. Keep Terraform and documentation changes incremental and environment-scoped.
6. Validate only with safe, relevant commands.
7. Summarize changed files, validation performed, and any documentation sync decisions.

## Forbidden Actions

- Do not create or modify frontend or backend application code in this repository.
- Do not move detailed ArgoCD workload manifests into this repository.
- Do not run Terraform write/state commands unless explicitly requested: `apply`, `destroy`, `import`, `state`, `taint`, `untaint`, or similar operations.
- Do not run GCP, Kubernetes, or ArgoCD write commands unless explicitly requested.
- Do not broaden IAM roles without explicit approval and a documented reason.
- Do not commit plaintext secrets, generated credentials, kubeconfigs, `.env` files, or token values.
- Do not add new validation scripts, OpenCode agents, or OpenCode config unless the user explicitly asks for them.

## Documentation Sync

After any meaningful change, check whether the following need updates:

- `tasks/current-focus.md`
- `docs/architecture/target-architecture.md`
- `docs/architecture/roadmap.md`
- `docs/architecture/naming-conventions.md`
- `docs/adr/README.md`
- Relevant ADRs under `docs/adr/`
- Relevant backlog documents under `docs/backlog/`
- This `AGENTS.md` file

Create or update an ADR when a structural decision changes repository boundaries, CI/CD strategy, Terraform ownership, network topology, security posture, or runtime architecture.
