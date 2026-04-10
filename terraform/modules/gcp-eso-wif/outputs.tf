output "wif_audience" {
  description = "Audience usado por workloads federadas no Google STS."
  value = var.create ? "//iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.wif_pool_id}/providers/${var.wif_provider_id}" : null
}

output "wif_pool_id" {
  description = "ID do workload identity pool criado."
  value       = var.create ? google_iam_workload_identity_pool.this[0].workload_identity_pool_id : null
}

output "wif_provider_id" {
  description = "ID do workload identity provider criado."
  value       = var.create ? google_iam_workload_identity_pool_provider.this[0].workload_identity_pool_provider_id : null
}

output "allowed_kubernetes_subjects" {
  description = "Subjects federados permitidos para autenticacao."
  value       = local.sa_subjects
}

output "impersonation_service_account_email" {
  description = "Service account GCP usada para impersonation (quando habilitada)."
  value       = var.create && var.use_service_account_impersonation ? google_service_account.eso[0].email : null
}