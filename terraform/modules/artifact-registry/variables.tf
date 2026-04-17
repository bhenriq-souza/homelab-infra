variable "create" {
  description = "Habilita a criacao dos recursos de Artifact Registry."
  type        = bool
  default     = false
}

variable "manage_project_services" {
  description = "Quando true, habilita e gerencia APIs necessarias no projeto GCP."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "Project ID GCP onde o registry sera criado."
  type        = string
}

variable "location" {
  description = "Regiao do Artifact Registry."
  type        = string
  default     = "us-central1"
}

variable "repository_id" {
  description = "ID do repositorio no Artifact Registry."
  type        = string
  default     = "homelab-apps"
}

variable "description" {
  description = "Descricao do repositorio."
  type        = string
  default     = "Registry de imagens Docker para aplicacoes do homelab"
}

variable "retention_days" {
  description = "Dias para reter imagens antes de cleanup automatico. Null desabilita."
  type        = number
  default     = null
}

variable "keep_minimum_versions" {
  description = "Numero minimo de versoes a manter por imagem. Null desabilita."
  type        = number
  default     = 10
}

variable "create_reader_service_account" {
  description = "Cria SA com permissao de leitura no registry (para image pull no cluster)."
  type        = bool
  default     = true
}

variable "reader_service_account_id" {
  description = "Account ID da SA de leitura do registry."
  type        = string
  default     = "ar-reader"
}

variable "create_reader_sa_key" {
  description = "Cria chave JSON para a SA de leitura."
  type        = bool
  default     = true
}

variable "store_reader_key_in_secret_manager" {
  description = "Armazena a chave da SA de leitura no GCP Secret Manager."
  type        = bool
  default     = true
}

variable "reader_key_secret_id" {
  description = "Secret ID no Secret Manager para a chave da SA de leitura."
  type        = string
  default     = "homelab-ar-reader-sa-key"
}
