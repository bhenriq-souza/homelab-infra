locals {
  required_services = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  sa_subjects = [
    for ksa in var.allowed_kubernetes_service_accounts :
    "system:serviceaccount:${ksa.namespace}:${ksa.name}"
  ]

  sa_subject_conditions = [
    for ksa in var.allowed_kubernetes_service_accounts :
    "(assertion['kubernetes.io']['namespace']=='${ksa.namespace}' && assertion['kubernetes.io']['serviceaccount']['name']=='${ksa.name}')"
  ]

  provider_attribute_condition = var.attribute_condition != "" ? var.attribute_condition : (
    length(local.sa_subject_conditions) > 0 ? join(" || ", local.sa_subject_conditions) : "true"
  )

  subject_members = {
    for subject in local.sa_subjects :
    subject => "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.wif_pool_id}/subject/${subject}"
  }

  direct_secret_subject_bindings = {
    for item in flatten([
      for secret_id in var.allowed_secret_ids : [
        for subject in local.sa_subjects : {
          key       = "${secret_id}::${subject}"
          secret_id = secret_id
          subject   = subject
        }
      ]
    ]) :
    item.key => item
  }
}

resource "google_project_service" "required" {
  for_each = var.create ? local.required_services : toset([])

  project = var.project_id
  service = each.value
}

resource "google_iam_workload_identity_pool" "this" {
  count = var.create ? 1 : 0

  workload_identity_pool_id = var.wif_pool_id
  display_name              = "Homelab K3s WIF Pool"
  description               = "Federacao para ESO no cluster K3s homelab"
  disabled                  = false

  depends_on = [google_project_service.required]
}

resource "google_iam_workload_identity_pool_provider" "this" {
  count = var.create ? 1 : 0

  workload_identity_pool_id          = google_iam_workload_identity_pool.this[0].workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "Homelab K3s OIDC Provider"
  description                        = "Provider OIDC para tokens de ServiceAccount do K3s"
  disabled                           = false
  attribute_mapping = {
    "google.subject"                  = "assertion.sub"
    "attribute.namespace"             = "assertion['kubernetes.io']['namespace']"
    "attribute.service_account_name"  = "assertion['kubernetes.io']['serviceaccount']['name']"
    "attribute.pod"                   = "assertion['kubernetes.io']['pod']['name']"
  }
  attribute_condition = local.provider_attribute_condition

  oidc {
    issuer_uri = var.kubernetes_issuer_uri
  }

  depends_on = [google_iam_workload_identity_pool.this]
}

resource "google_service_account" "eso" {
  count = var.create && var.use_service_account_impersonation ? 1 : 0

  project      = var.project_id
  account_id   = var.gcp_service_account_id
  display_name = "ESO Secret Manager Reader"
  description  = "Service account usada pela federacao de workloads do ESO"
}

resource "google_service_account_iam_member" "ksa_impersonation" {
  for_each = var.create && var.use_service_account_impersonation ? local.subject_members : {}

  service_account_id = google_service_account.eso[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value
}

resource "google_secret_manager_secret_iam_member" "secret_accessor_impersonation" {
  for_each = var.create && var.use_service_account_impersonation ? toset(var.allowed_secret_ids) : toset([])

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.eso[0].email}"
}

resource "google_secret_manager_secret_iam_member" "secret_accessor_direct" {
  for_each = var.create && !var.use_service_account_impersonation ? local.direct_secret_subject_bindings : {}

  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.subject_members[each.value.subject]
}