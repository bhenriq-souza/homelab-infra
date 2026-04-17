output "repository_id" {
  description = "ID do repositorio Artifact Registry criado."
  value       = var.create ? google_artifact_registry_repository.this[0].repository_id : null
}

output "repository_url" {
  description = "URL base do repositorio para push/pull de imagens."
  value       = var.create ? "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}" : null
}

output "reader_service_account_email" {
  description = "Email da SA de leitura do registry."
  value       = var.create && var.create_reader_service_account ? google_service_account.reader[0].email : null
}

output "reader_key_secret_id" {
  description = "Secret ID da chave da SA de leitura no Secret Manager."
  value       = var.create && var.create_reader_service_account && var.create_reader_sa_key && var.store_reader_key_in_secret_manager ? google_secret_manager_secret.reader_sa_key[0].secret_id : null
}
