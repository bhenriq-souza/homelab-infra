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
  format        = "NPM"

  cleanup_policy_dry_run = false

  dynamic "cleanup_policies" {
    for_each = var.dev_retention_days != null ? [1] : []
    content {
      id     = "delete-dev-artifacts"
      action = "DELETE"
      condition {
        tag_state    = "TAGGED"
        tag_prefixes = var.dev_tag_prefixes
        older_than   = "${var.dev_retention_days * 24 * 60 * 60}s"
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
