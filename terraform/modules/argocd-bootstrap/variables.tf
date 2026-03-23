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
