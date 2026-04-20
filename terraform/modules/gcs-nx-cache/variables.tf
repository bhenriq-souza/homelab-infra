variable "create" {
  description = "Habilita a criacao dos recursos do bucket GCS para cache Nx."
  type        = bool
  default     = false
}

variable "manage_project_services" {
  description = "Quando true, habilita e gerencia APIs necessarias no projeto GCP."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "Project ID GCP onde o bucket sera criado."
  type        = string
}

variable "location" {
  description = "Regiao do bucket GCS."
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Nome do bucket GCS para cache remoto do Nx."
  type        = string
  default     = "typescript-nx-cache"
}

variable "lifecycle_age_days" {
  description = "Dias para reter objetos antes de deletar automaticamente. Alinhado com o ADR-0001 (90 dias)."
  type        = number
  default     = 90
}

variable "force_destroy" {
  description = "Quando true, permite destruir o bucket mesmo com objetos. Usar com cautela."
  type        = bool
  default     = false
}
