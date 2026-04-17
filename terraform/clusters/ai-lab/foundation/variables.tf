variable "project_id" {
  description = "Project ID GCP que hospedara a fundacao do ai-lab."
  type        = string
}

variable "region" {
  description = "Regiao principal do ai-lab na GCP."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona principal da VM do ai-lab."
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefixo base para nomes dos recursos do ai-lab."
  type        = string
  default     = "ai-lab"
}

variable "environment_name" {
  description = "Nome logico do ambiente cloud."
  type        = string
  default     = "gcp-lab"
}

variable "manage_project_services" {
  description = "Quando true, habilita as APIs GCP necessarias para a fundacao."
  type        = bool
  default     = true
}

variable "network_name" {
  description = "Nome explicito da VPC. Quando vazio, usa o prefixo padrao."
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Nome explicito da subnet. Quando vazio, usa o prefixo padrao."
  type        = string
  default     = ""
}

variable "subnet_cidr" {
  description = "CIDR principal da subnet do ai-lab."
  type        = string
  default     = "10.60.0.0/24"
}

variable "private_ip_google_access" {
  description = "Habilita Private Google Access na subnet."
  type        = bool
  default     = true
}

variable "admin_source_ranges" {
  description = "CIDRs administrativos autorizados a acessar SSH e futuras portas de operacao."
  type        = list(string)
}

variable "instance_name" {
  description = "Nome explicito da VM. Quando vazio, usa o prefixo padrao."
  type        = string
  default     = ""
}

variable "machine_type" {
  description = "Tipo de maquina da VM base do ai-lab."
  type        = string
  default     = "e2-standard-4"
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

variable "boot_disk_image" {
  description = "Imagem base do boot disk da VM."
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
}

variable "boot_disk_size_gb" {
  description = "Tamanho do boot disk da VM em GB."
  type        = number
  default     = 50
}

variable "boot_disk_type" {
  description = "Tipo do boot disk da VM."
  type        = string
  default     = "pd-balanced"
}

variable "data_disk_size_gb" {
  description = "Tamanho do disco de dados em GB. Use 0 para nao criar disco adicional."
  type        = number
  default     = 200
}

variable "data_disk_type" {
  description = "Tipo do disco de dados adicional."
  type        = string
  default     = "pd-balanced"
}

variable "guest_accelerator_type" {
  description = "Tipo da GPU anexada a VM. Quando null, nao anexa GPU."
  type        = string
  default     = null
  nullable    = true
}

variable "guest_accelerator_count" {
  description = "Quantidade de GPUs anexadas a VM. Use 0 para nao anexar GPU."
  type        = number
  default     = 0
}

variable "assign_public_ip" {
  description = "Quando true, reserva e anexa IP publico estatico para a VM."
  type        = bool
  default     = true
}

variable "enable_future_k3s_api_firewall" {
  description = "Quando true, libera a porta 6443 para a futura API do K3s."
  type        = bool
  default     = false
}

variable "service_ingress_rules" {
  description = "Regras adicionais de firewall para expor servicos especificos da VM a origens confiaveis."
  type = list(object({
    name          = string
    description   = optional(string)
    priority      = optional(number)
    source_ranges = list(string)
    protocol      = optional(string)
    ports         = optional(list(string))
  }))
  default = []
}

variable "instance_service_account_id" {
  description = "Account ID da service account dedicada da VM."
  type        = string
  default     = "ai-lab-foundation-vm"
}

variable "instance_service_account_roles" {
  description = "Papeis de projeto a serem vinculados a service account da VM."
  type        = list(string)
  default     = ["roles/logging.logWriter", "roles/monitoring.metricWriter"]
}

variable "instance_metadata" {
  description = "Metadados adicionais da VM."
  type        = map(string)
  default     = {}
}

variable "instance_ssh_public_keys" {
  description = "Entradas de chave publica no formato usuario:chave para metadata ssh-keys."
  type        = list(string)
  default     = []
}

variable "instance_startup_script" {
  description = "Startup script opcional da VM. Nao instalar K3s nesta etapa."
  type        = string
  default     = ""
}

variable "instance_network_tags" {
  description = "Tags de rede adicionais da VM."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels adicionais aplicadas aos recursos suportados."
  type        = map(string)
  default     = {}
}