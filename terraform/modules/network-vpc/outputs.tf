output "network_name" {
  description = "Nome da VPC criada."
  value       = google_compute_network.this.name
}

output "network_self_link" {
  description = "Self link da VPC criada."
  value       = google_compute_network.this.self_link
}

output "subnet_name" {
  description = "Nome da subnet criada."
  value       = google_compute_subnetwork.this.name
}

output "subnet_self_link" {
  description = "Self link da subnet criada."
  value       = google_compute_subnetwork.this.self_link
}

output "subnet_cidr" {
  description = "CIDR configurado na subnet."
  value       = google_compute_subnetwork.this.ip_cidr_range
}