output "namespaces" {
  description = "Namespaces criados para o ambiente."
  value       = sort([for ns in kubernetes_namespace_v1.environment : ns.metadata[0].name])
}
