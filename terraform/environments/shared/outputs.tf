output "argocd_namespace" {
  description = "Namespace onde o Argo CD foi instalado."
  value       = module.argocd_bootstrap.argocd_namespace
}

output "bootstrap_application_name" {
  description = "Nome da aplicacao raiz de bootstrap do GitOps."
  value       = module.argocd_bootstrap.bootstrap_application_name
}
