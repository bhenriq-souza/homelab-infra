module "argocd_bootstrap" {
  source = "../../modules/argocd-bootstrap"

  argocd_namespace                           = var.argocd_namespace
  argocd_chart_version                       = var.argocd_chart_version
  argocd_ingress_enabled                     = var.argocd_ingress_enabled
  argocd_ingress_hostname                    = var.argocd_ingress_hostname
  argocd_ingress_class_name                  = var.argocd_ingress_class_name
  argocd_ingress_tls_enabled                 = var.argocd_ingress_tls_enabled
  argocd_ingress_tls_secret_name             = var.argocd_ingress_tls_secret_name
  argocd_ingress_cert_manager_cluster_issuer = var.argocd_ingress_cert_manager_cluster_issuer
  argocd_helm_values_override                = var.argocd_helm_values_override
  gitops_repo_url                            = var.gitops_repo_url
  gitops_target_revision                     = var.gitops_target_revision
  gitops_root_path                           = var.gitops_root_path
}

module "gcp_eso_wif" {
  source = "../../modules/gcp-eso-wif"

  create                               = var.gcp_eso_wif_enabled
  project_id                           = var.gcp_project_id
  project_number                       = var.gcp_project_number
  wif_pool_id                          = var.gcp_wif_pool_id
  wif_provider_id                      = var.gcp_wif_provider_id
  kubernetes_issuer_uri                = var.kubernetes_oidc_issuer_uri
  allowed_kubernetes_service_accounts  = var.gcp_allowed_kubernetes_service_accounts
  allowed_secret_ids                   = var.gcp_allowed_secret_ids
  use_service_account_impersonation    = var.gcp_use_service_account_impersonation
  gcp_service_account_id               = var.gcp_eso_service_account_id
  attribute_condition                  = var.gcp_wif_attribute_condition
}
