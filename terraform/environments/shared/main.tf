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
