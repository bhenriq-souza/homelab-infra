output "network_name" {
  description = "Nome da VPC do ai-lab."
  value       = module.network_vpc.network_name
}

output "subnet_name" {
  description = "Nome da subnet principal do ai-lab."
  value       = module.network_vpc.subnet_name
}

output "subnet_cidr" {
  description = "CIDR principal da subnet do ai-lab."
  value       = module.network_vpc.subnet_cidr
}

output "vm_name" {
  description = "Nome da VM base do ai-lab."
  value       = module.compute_vm.instance_name
}

output "vm_internal_ip" {
  description = "IP interno da VM base do ai-lab."
  value       = module.compute_vm.internal_ip
}

output "vm_external_ip" {
  description = "IP publico da VM base do ai-lab."
  value       = module.compute_vm.external_ip
}

output "vm_data_disk_name" {
  description = "Nome do disco de dados anexado a VM."
  value       = module.compute_vm.data_disk_name
}

output "vm_guest_accelerator_type" {
  description = "Tipo da GPU anexada a VM base do ai-lab."
  value       = module.compute_vm.guest_accelerator_type
}

output "vm_service_account_email" {
  description = "Email da service account dedicada da VM."
  value       = google_service_account.vm.email
}