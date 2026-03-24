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

variable "argocd_helm_values_override" {
  description = "Valores extras/override para o chart argo-cd no ambiente shared."
  type        = any
  default     = {}
}

variable "argocd_ingress_enabled" {
  description = "Habilita Ingress para acesso ao Argo CD no ambiente shared."
  type        = bool
  default     = false
}

variable "argocd_ingress_hostname" {
  description = "Hostname do Ingress do Argo CD no ambiente shared."
  type        = string
  default     = ""
}

variable "argocd_ingress_class_name" {
  description = "IngressClass para o Ingress do Argo CD."
  type        = string
  default     = "traefik"
}

variable "argocd_ingress_tls_enabled" {
  description = "Habilita TLS no Ingress do Argo CD."
  type        = bool
  default     = true
}

variable "argocd_ingress_tls_secret_name" {
  description = "Nome do secret TLS do Ingress do Argo CD."
  type        = string
  default     = "argocd-server-tls"
}

variable "argocd_ingress_cert_manager_cluster_issuer" {
  description = "ClusterIssuer do cert-manager para o certificado TLS do Argo CD."
  type        = string
  default     = ""
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
