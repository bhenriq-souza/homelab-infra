variable "create" {
  description = "Habilita a criacao dos recursos de WIF para GitHub Actions."
  type        = bool
  default     = false
}

variable "manage_project_services" {
  description = "Quando true, habilita e gerencia APIs necessarias no projeto GCP."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "Project ID GCP."
  type        = string
}

variable "project_number" {
  description = "Project number do projeto GCP. Necessario para principalSet://."
  type        = string
  default     = ""

  validation {
    condition     = !var.create || var.project_number != ""
    error_message = "project_number e obrigatorio quando create=true."
  }
}

variable "wif_pool_id" {
  description = "ID do Workload Identity Pool para GitHub Actions."
  type        = string
  default     = "github-actions-pool"
}

variable "wif_provider_id" {
  description = "ID do Workload Identity Provider OIDC para GitHub Actions."
  type        = string
  default     = "github-actions-provider"
}

variable "github_organization" {
  description = "Owner/organization do GitHub (usado na attribute condition)."
  type        = string
}

variable "allowed_repositories" {
  description = "Lista de repositorios GitHub autorizados (formato: owner/repo)."
  type        = list(string)
  default     = []

  validation {
    condition     = !var.create || length(var.allowed_repositories) > 0
    error_message = "Defina ao menos um repositorio em allowed_repositories quando create=true."
  }
}

variable "dev_branches" {
  description = "Branches que representam o ambiente dev."
  type        = list(string)
  default     = ["develop"]
}

variable "prd_branches" {
  description = "Branches que representam o ambiente prd."
  type        = list(string)
  default     = ["main"]
}

variable "ci_service_account_id" {
  description = "Account ID da service account GCP usada pelo CI."
  type        = string
  default     = "github-actions-ci"
}

variable "artifact_registry_repository" {
  description = "Nome do repositorio Artifact Registry para conceder permissao de escrita. Vazio ignora."
  type        = string
  default     = ""
}

variable "artifact_registry_location" {
  description = "Regiao do Artifact Registry."
  type        = string
  default     = "us-central1"
}

variable "attribute_condition" {
  description = "Condicao CEL opcional do provider. Quando vazio, e gerada automaticamente para os repos permitidos."
  type        = string
  default     = ""
}
