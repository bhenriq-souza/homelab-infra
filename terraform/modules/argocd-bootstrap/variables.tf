variable "argocd_namespace" {
  description = "Namespace compartilhado do Argo CD."
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Versao do chart argo-cd."
  type        = string
  default     = null
  nullable    = true
}

variable "bootstrap_application_name" {
  description = "Nome da aplicacao raiz de bootstrap."
  type        = string
  default     = "homelab-root"
}

variable "gitops_repo_url" {
  description = "URL do repositorio GitOps."
  type        = string
}

variable "gitops_target_revision" {
  description = "Branch, tag ou commit usado no bootstrap."
  type        = string
  default     = "main"
}

variable "gitops_root_path" {
  description = "Path da aplicacao raiz no repositorio GitOps."
  type        = string
  default     = "gitops/bootstrap/root"
}

variable "argocd_helm_values_override" {
  description = "Valores extras/override para o chart argo-cd (mesclados apos o baseline do modulo)."
  type        = any
  default     = {}
}

variable "argocd_ingress_enabled" {
  description = "Habilita Ingress para o argocd-server."
  type        = bool
  default     = false
}

variable "argocd_ingress_hostname" {
  description = "Hostname do Ingress do argocd-server."
  type        = string
  default     = ""
}

variable "argocd_ingress_class_name" {
  description = "IngressClass usada para expor o argocd-server."
  type        = string
  default     = "traefik"
}

variable "argocd_ingress_tls_enabled" {
  description = "Habilita TLS no Ingress do argocd-server."
  type        = bool
  default     = true
}

variable "argocd_ingress_tls_secret_name" {
  description = "Nome do secret TLS usado pelo Ingress do argocd-server."
  type        = string
  default     = "argocd-server-tls"
}

variable "argocd_ingress_cert_manager_cluster_issuer" {
  description = "ClusterIssuer do cert-manager para emitir o certificado TLS do Ingress do Argo CD."
  type        = string
  default     = ""
}
