variable "create" {
  description = "Habilita a criacao dos recursos de Artifact Registry formato npm."
  type        = bool
  default     = false
}

variable "manage_project_services" {
  description = "Quando true, habilita e gerencia APIs necessarias no projeto GCP."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "Project ID GCP onde o registry npm sera criado."
  type        = string
}

variable "location" {
  description = "Regiao do Artifact Registry."
  type        = string
  default     = "us-central1"
}

variable "repository_id" {
  description = "ID do repositorio npm no Artifact Registry."
  type        = string
  default     = "typescript-packages-dev"
}

variable "description" {
  description = "Descricao do repositorio."
  type        = string
  default     = "Registry npm para artefatos dev de PRs do monorepo typescript-common-packages"
}

variable "dev_retention_days" {
  description = "Dias para reter artefatos dev (taggeados com prefixos em dev_tag_prefixes) antes de cleanup. Null desabilita."
  type        = number
  default     = 30
}

variable "dev_tag_prefixes" {
  description = "Prefixos de dist-tag npm considerados como 'dev' e alvo da cleanup policy de retencao."
  type        = list(string)
  default     = ["dev"]
}

variable "keep_minimum_versions" {
  description = "Numero minimo de versoes a manter por pacote (KEEP policy). Null desabilita."
  type        = number
  default     = null
}
