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

variable "namespaces" {
  description = "Namespaces do ambiente dev."
  type        = list(string)
  default     = ["dev-apps"]
}
