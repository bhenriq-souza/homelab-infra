variable "project_id" {
  description = "Project ID GCP onde a rede sera criada."
  type        = string
}

variable "network_name" {
  description = "Nome da VPC."
  type        = string
}

variable "network_description" {
  description = "Descricao opcional da VPC."
  type        = string
  default     = ""
}

variable "routing_mode" {
  description = "Modo de roteamento da VPC."
  type        = string
  default     = "REGIONAL"
}

variable "delete_default_routes_on_create" {
  description = "Remove a rota default criada junto com a VPC."
  type        = bool
  default     = false
}

variable "region" {
  description = "Regiao da subnet principal."
  type        = string
}

variable "subnet_name" {
  description = "Nome da subnet principal."
  type        = string
}

variable "subnet_description" {
  description = "Descricao opcional da subnet."
  type        = string
  default     = ""
}

variable "subnet_cidr" {
  description = "CIDR principal da subnet."
  type        = string
}

variable "private_ip_google_access" {
  description = "Habilita Private Google Access na subnet."
  type        = bool
  default     = true
}