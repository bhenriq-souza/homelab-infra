locals {
  required_services = toset([
    "storage.googleapis.com"
  ])
}

resource "google_project_service" "required" {
  for_each = var.create && var.manage_project_services ? local.required_services : toset([])

  project = var.project_id
  service = each.value
}

resource "google_storage_bucket" "this" {
  count = var.create ? 1 : 0

  project  = var.project_id
  name     = var.bucket_name
  location = var.location

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = var.lifecycle_age_days
    }
    action {
      type = "Delete"
    }
  }

  force_destroy = var.force_destroy

  depends_on = [google_project_service.required]
}
