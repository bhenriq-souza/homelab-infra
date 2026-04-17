output "wif_provider_name" {
  description = "Nome completo do provider para uso no GitHub Actions (workload_identity_provider)."
  value       = var.create ? "projects/${var.project_number}/locations/global/workloadIdentityPools/${var.wif_pool_id}/providers/${var.wif_provider_id}" : null
}

output "wif_pool_id" {
  description = "ID do workload identity pool criado."
  value       = var.create ? google_iam_workload_identity_pool.this[0].workload_identity_pool_id : null
}

output "wif_provider_id" {
  description = "ID do workload identity provider criado."
  value       = var.create ? google_iam_workload_identity_pool_provider.this[0].workload_identity_pool_provider_id : null
}

output "ci_service_account_email" {
  description = "Email da SA de CI para uso no GitHub Actions."
  value       = var.create ? google_service_account.ci[0].email : null
}
