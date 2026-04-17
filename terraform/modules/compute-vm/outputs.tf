output "instance_name" {
  description = "Nome da VM criada."
  value       = google_compute_instance.this.name
}

output "instance_self_link" {
  description = "Self link da VM criada."
  value       = google_compute_instance.this.self_link
}

output "internal_ip" {
  description = "IP interno primario da VM."
  value       = google_compute_instance.this.network_interface[0].network_ip
}

output "external_ip" {
  description = "IP publico primario da VM."
  value       = try(google_compute_instance.this.network_interface[0].access_config[0].nat_ip, null)
}

output "data_disk_name" {
  description = "Nome do disco de dados anexado a VM."
  value       = try(google_compute_disk.data[0].name, null)
}

output "guest_accelerator_type" {
  description = "Tipo da GPU anexada a VM."
  value       = try(google_compute_instance.this.guest_accelerator[0].type, null)
}