output "argocd_namespace" {
  description = "Namespace onde o Argo CD foi instalado."
  value       = module.argocd_bootstrap.argocd_namespace
}

output "bootstrap_application_name" {
  description = "Nome da aplicacao raiz de bootstrap do GitOps."
  value       = module.argocd_bootstrap.bootstrap_application_name
}

output "gcp_wif_audience" {
  description = "Audience para configurar o ClusterSecretStore com workloadIdentityFederation."
  value       = module.gcp_eso_wif.wif_audience
}

output "gcp_wif_pool_id" {
  description = "ID do WIF Pool criado para ESO."
  value       = module.gcp_eso_wif.wif_pool_id
}

output "gcp_wif_provider_id" {
  description = "ID do WIF Provider criado para ESO."
  value       = module.gcp_eso_wif.wif_provider_id
}

output "gcp_eso_impersonation_sa" {
  description = "Email da SA GCP usada para impersonation pelo ESO."
  value       = module.gcp_eso_wif.impersonation_service_account_email
}

# --- Artifact Registry ---

output "artifact_registry_url" {
  description = "URL base do Artifact Registry para push/pull de imagens."
  value       = module.artifact_registry.repository_url
}

output "artifact_registry_reader_sa" {
  description = "Email da SA de leitura do Artifact Registry."
  value       = module.artifact_registry.reader_service_account_email
}

output "artifact_registry_reader_key_secret_id" {
  description = "Secret ID da chave da SA de leitura no Secret Manager."
  value       = module.artifact_registry.reader_key_secret_id
}

# --- GitHub Actions WIF ---

output "github_wif_provider_name" {
  description = "Nome completo do WIF provider para configurar no GitHub Actions."
  value       = module.gcp_github_wif.wif_provider_name
}

output "github_ci_service_account_email" {
  description = "Email da SA de CI para uso no GitHub Actions."
  value       = module.gcp_github_wif.ci_service_account_email
}
