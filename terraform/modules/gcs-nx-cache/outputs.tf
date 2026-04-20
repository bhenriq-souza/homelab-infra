output "bucket_name" {
  description = "Nome do bucket GCS criado para cache Nx."
  value       = var.create ? google_storage_bucket.this[0].name : null
}

output "bucket_url" {
  description = "URL gs:// do bucket para configuracao do remote cache Nx."
  value       = var.create ? google_storage_bucket.this[0].url : null
}

output "bucket_self_link" {
  description = "Self-link do bucket para uso em bindings IAM."
  value       = var.create ? google_storage_bucket.this[0].self_link : null
}
