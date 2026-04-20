output "repository_id" {
  description = "ID do repositorio npm Artifact Registry criado."
  value       = var.create ? google_artifact_registry_repository.this[0].repository_id : null
}

output "repository_name" {
  description = "Resource name (projects/.../repositories/...) para uso em bindings IAM."
  value       = var.create ? google_artifact_registry_repository.this[0].name : null
}

output "repository_url" {
  description = "URL base do registry npm para configuracao em .npmrc."
  value       = var.create ? "https://${var.location}-npm.pkg.dev/${var.project_id}/${var.repository_id}/" : null
}

output "registry_host" {
  description = "Host do registry (sem scheme/path) para uso em autenticacao."
  value       = var.create ? "${var.location}-npm.pkg.dev" : null
}
