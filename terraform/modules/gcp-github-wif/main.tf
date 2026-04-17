locals {
  required_services = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com"
  ])

  repo_conditions = [
    for repo in var.allowed_repositories :
    "assertion.repository=='${repo}'"
  ]

  branch_conditions_dev = [
    for branch in var.dev_branches :
    "assertion.ref=='refs/heads/${branch}'"
  ]

  branch_conditions_prd = [
    for branch in var.prd_branches :
    "assertion.ref=='refs/heads/${branch}'"
  ]

  provider_attribute_condition = var.attribute_condition != "" ? var.attribute_condition : (
    length(local.repo_conditions) > 0 ? (
      "assertion.repository_owner=='${var.github_organization}' && (${join(" || ", local.repo_conditions)})"
    ) : "assertion.repository_owner=='${var.github_organization}'"
  )
}

resource "google_project_service" "required" {
  for_each = var.create && var.manage_project_services ? local.required_services : toset([])

  project = var.project_id
  service = each.value
}

resource "google_iam_workload_identity_pool" "this" {
  count = var.create ? 1 : 0

  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub Actions WIF Pool"
  description               = "Federacao OIDC para GitHub Actions CI/CD"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "this" {
  count = var.create ? 1 : 0

  workload_identity_pool_id          = google_iam_workload_identity_pool.this[0].workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub Actions OIDC Provider"
  description                        = "Provider OIDC para tokens do GitHub Actions"
  disabled                           = false

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
    "attribute.actor"            = "assertion.actor"
  }

  attribute_condition = local.provider_attribute_condition

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_iam_workload_identity_pool.this]
}

resource "google_service_account" "ci" {
  count = var.create ? 1 : 0

  project      = var.project_id
  account_id   = var.ci_service_account_id
  display_name = "GitHub Actions CI"
  description  = "Service account usada pelo GitHub Actions para push de imagens no Artifact Registry"
}

resource "google_service_account_iam_member" "wif_binding" {
  for_each = var.create ? toset(var.allowed_repositories) : toset([])

  service_account_id = google_service_account.ci[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.wif_pool_id}/attribute.repository/${each.value}"
}

resource "google_artifact_registry_repository_iam_member" "ci_writer" {
  count = var.create && var.artifact_registry_repository != "" ? 1 : 0

  project    = var.project_id
  location   = var.artifact_registry_location
  repository = var.artifact_registry_repository
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.ci[0].email}"
}
