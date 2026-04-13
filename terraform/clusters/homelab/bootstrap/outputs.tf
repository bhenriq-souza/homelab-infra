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
