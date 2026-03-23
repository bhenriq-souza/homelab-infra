module "argocd_bootstrap" {
  source = "../../modules/argocd-bootstrap"

  argocd_namespace       = var.argocd_namespace
  argocd_chart_version   = var.argocd_chart_version
  gitops_repo_url        = var.gitops_repo_url
  gitops_target_revision = var.gitops_target_revision
  gitops_root_path       = var.gitops_root_path
}
