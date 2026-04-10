variable "create" {
  description = "Habilita a criacao dos recursos de WIF para ESO."
  type        = bool
  default     = false
}

variable "project_id" {
  description = "Project ID que contem os secrets no Secret Manager."
  type        = string
}

variable "project_number" {
  description = "Project number do projeto GCP. Necessario para principal:// e audience."
  type        = string
  default     = ""

  validation {
    condition     = !var.create || var.project_number != ""
    error_message = "project_number e obrigatorio quando create=true."
  }
}

variable "wif_pool_id" {
  description = "ID do Workload Identity Pool."
  type        = string
  default     = "homelab-k3s-pool"
}

variable "wif_provider_id" {
  description = "ID do Workload Identity Provider OIDC."
  type        = string
  default     = "homelab-k3s-provider"
}

variable "kubernetes_issuer_uri" {
  description = "Issuer URI OIDC do cluster Kubernetes (precisa ser acessivel pela Google STS)."
  type        = string
  default     = ""

  validation {
    condition     = !var.create || var.kubernetes_issuer_uri != ""
    error_message = "kubernetes_issuer_uri e obrigatorio quando create=true."
  }
}

variable "allowed_kubernetes_service_accounts" {
  description = "ServiceAccounts Kubernetes autorizadas a federar para leitura de secrets."
  type = list(object({
    namespace = string
    name      = string
  }))
  default = [
    {
      namespace = "external-secrets"
      name      = "eso-gcp-dev"
    },
    {
      namespace = "external-secrets"
      name      = "eso-gcp-prd"
    }
  ]
}

variable "allowed_secret_ids" {
  description = "Lista de Secret IDs no Secret Manager que o ESO pode ler."
  type        = list(string)
  default     = []

  validation {
    condition     = !var.create || length(var.allowed_secret_ids) > 0
    error_message = "Defina ao menos um secret em allowed_secret_ids quando create=true."
  }
}

variable "use_service_account_impersonation" {
  description = "Quando true, usa SA GCP intermediaria (avancado). Quando false, usa principal federado direto (recomendado para ESO com serviceAccountRef)."
  type        = bool
  default     = false
}

variable "gcp_service_account_id" {
  description = "Account ID da service account GCP usada na impersonation."
  type        = string
  default     = "eso-secrets-reader"
}

variable "attribute_condition" {
  description = "Condicao CEL opcional do provider. Quando vazio, e gerada automaticamente para SAs autorizadas."
  type        = string
  default     = ""
}