output "argocd_namespace" {
  description = "Namespace do Argo CD."
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "bootstrap_application_name" {
  description = "Nome da aplicacao raiz criada no Argo CD."
  value       = var.bootstrap_application_name
}
