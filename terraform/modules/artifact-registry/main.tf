locals {
  required_services = toset([
    "artifactregistry.googleapis.com"
  ])
}

resource "google_project_service" "required" {
  for_each = var.create && var.manage_project_services ? local.required_services : toset([])

  project = var.project_id
  service = each.value
}

resource "google_artifact_registry_repository" "this" {
  count = var.create ? 1 : 0

  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  dynamic "cleanup_policies" {
    for_each = var.retention_days != null ? [1] : []
    content {
      id     = "delete-old-images"
      action = "DELETE"
      condition {
        older_than = "${var.retention_days * 24 * 60 * 60}s"
      }
    }
  }

  dynamic "cleanup_policies" {
    for_each = var.keep_minimum_versions != null ? [1] : []
    content {
      id     = "keep-minimum-versions"
      action = "KEEP"
      most_recent_versions {
        keep_count = var.keep_minimum_versions
      }
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_service_account" "reader" {
  count = var.create && var.create_reader_service_account ? 1 : 0

  project      = var.project_id
  account_id   = var.reader_service_account_id
  display_name = "Artifact Registry Reader"
  description  = "Service account para pull de imagens privadas do Artifact Registry"
}

resource "google_artifact_registry_repository_iam_member" "reader" {
  count = var.create && var.create_reader_service_account ? 1 : 0

  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this[0].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.reader[0].email}"
}

resource "google_service_account_key" "reader" {
  count = var.create && var.create_reader_service_account && var.create_reader_sa_key ? 1 : 0

  service_account_id = google_service_account.reader[0].name
}

resource "google_secret_manager_secret" "reader_sa_key" {
  count = var.create && var.create_reader_service_account && var.create_reader_sa_key && var.store_reader_key_in_secret_manager ? 1 : 0

  project   = var.project_id
  secret_id = var.reader_key_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "reader_sa_key" {
  count = var.create && var.create_reader_service_account && var.create_reader_sa_key && var.store_reader_key_in_secret_manager ? 1 : 0

  secret = google_secret_manager_secret.reader_sa_key[0].id
  secret_data = jsonencode({
    "auths" = {
      "${var.location}-docker.pkg.dev" = {
        "username" = "_json_key_base64"
        "password" = google_service_account_key.reader[0].private_key
      }
    }
  })
}
