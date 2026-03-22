variable "environment" {
  description = "Nome logico do ambiente, por exemplo dev ou prd."
  type        = string
}

variable "namespaces" {
  description = "Lista de namespaces a criar para o ambiente."
  type        = list(string)
  default     = []
}
