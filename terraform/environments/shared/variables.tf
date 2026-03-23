variable "kubeconfig_path" {
  description = "Caminho do kubeconfig usado para conectar ao cluster K3s."
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Contexto do kubeconfig. Quando vazio, usa o contexto atual."
  type        = string
  default     = ""
}

variable "argocd_namespace" {
  description = "Namespace compartilhado para o Argo CD."
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Versao do chart argo-cd. Use null para seguir a versao mais recente do repositorio Helm."
  type        = string
  default     = null
  nullable    = true
}

variable "gitops_repo_url" {
  description = "URL do repositorio Git que contem o diretorio gitops/."
  type        = string
}

variable "gitops_target_revision" {
  description = "Branch, tag ou commit para o bootstrap GitOps."
  type        = string
  default     = "main"
}

variable "gitops_root_path" {
  description = "Path no repositorio GitOps para a aplicacao raiz."
  type        = string
  default     = "gitops/bootstrap/root"
}
