variable "project_id" {
  description = "Project ID GCP da VM."
  type        = string
}

variable "instance_name" {
  description = "Nome da VM."
  type        = string
}

variable "zone" {
  description = "Zona onde a VM sera criada."
  type        = string
}

variable "machine_type" {
  description = "Tipo de maquina da VM."
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link da subnet conectada a VM."
  type        = string
}

variable "assign_public_ip" {
  description = "Quando true, anexa IP publico na interface primaria."
  type        = bool
  default     = true
}

variable "public_ip_address" {
  description = "IP publico estatico reservado para a VM. Quando null e assign_public_ip=true, usa IP efemero."
  type        = string
  default     = null
  nullable    = true
}

variable "can_ip_forward" {
  description = "Habilita IP forwarding na VM."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags de rede da VM."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels da VM."
  type        = map(string)
  default     = {}
}

variable "boot_disk_image" {
  description = "Imagem base do boot disk."
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Tamanho do boot disk em GB."
  type        = number
}

variable "boot_disk_type" {
  description = "Tipo do boot disk."
  type        = string
}

variable "data_disk_name" {
  description = "Nome do disco de dados."
  type        = string
  default     = ""
}

variable "data_disk_size_gb" {
  description = "Tamanho do disco de dados em GB. Use 0 para nao criar disco adicional."
  type        = number
  default     = 0
}

variable "data_disk_type" {
  description = "Tipo do disco de dados."
  type        = string
  default     = "pd-balanced"
}

variable "guest_accelerator_type" {
  description = "Tipo da GPU anexada a VM. Quando null, nao anexa acelerador." 
  type        = string
  default     = null
  nullable    = true
}

variable "guest_accelerator_count" {
  description = "Quantidade de GPUs anexadas a VM. Use 0 para nao anexar GPU." 
  type        = number
  default     = 0
}

variable "service_account_email" {
  description = "Email da service account anexada a VM. Quando null, nao anexa SA explicita."
  type        = string
  default     = null
  nullable    = true
}

variable "service_account_scopes" {
  description = "Scopes da service account anexada a VM."
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write"]
}

variable "metadata" {
  description = "Metadados adicionais da VM."
  type        = map(string)
  default     = {}
}

variable "ssh_public_keys" {
  description = "Entradas no formato usuario:chave-publica para metadata ssh-keys."
  type        = list(string)
  default     = []
}

variable "startup_script" {
  description = "Startup script opcional da VM."
  type        = string
  default     = ""
}

variable "enable_serial_port" {
  description = "Habilita serial console na VM."
  type        = bool
  default     = false
}

variable "instance_provisioning_model" {
  description = "Provisioning model da VM. Use STANDARD ou SPOT."
  type        = string
  default     = "SPOT"
}

variable "instance_termination_action" {
  description = "Acao quando uma VM SPOT for preemptada."
  type        = string
  default     = "STOP"
}

variable "automatic_restart" {
  description = "Reinicia automaticamente a VM quando o provisioning model permitir."
  type        = bool
  default     = true
}

variable "on_host_maintenance" {
  description = "Politica de manutencao do host."
  type        = string
  default     = "MIGRATE"
}

variable "desired_status" {
  description = "Estado desejado da VM apos criacao."
  type        = string
  default     = "RUNNING"
}

variable "shielded_secure_boot" {
  description = "Habilita secure boot na VM."
  type        = bool
  default     = false
}

variable "shielded_vtpm" {
  description = "Habilita vTPM na VM."
  type        = bool
  default     = true
}

variable "shielded_integrity_monitoring" {
  description = "Habilita integrity monitoring na VM."
  type        = bool
  default     = true
}