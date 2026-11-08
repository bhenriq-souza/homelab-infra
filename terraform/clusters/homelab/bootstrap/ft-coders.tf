# FT Coders (software factory): service account do orquestrador que roda no k3s, namespace factory.
# Spec 0022 do repositório ft-coders. Lê só os segredos de que precisa, um binding por segredo, e não tem
# papel no projeto. Os segredos já existem (criados à mão em 02/11/2026); aqui entra só o acesso.
# A chave da SA é criada com gcloud e gravada como factory-orchestrator-sa-key, fora do state do
# Terraform; o ESO a entrega ao pod pelo ClusterSecretStore gcp-sm-factory.

locals {
  ft_coders_orchestrator_secrets = [
    "factory-farmtech-ado-pat",
    "factory-farmtech-github-token",
    "factory-postgres-password",
  ]
}

resource "google_service_account" "ft_coders_orchestrator" {
  project      = var.gcp_project_id
  account_id   = "ft-coders-orchestrator"
  display_name = "FT Coders orchestrator (k3s, namespace factory)"
  description  = "Lê os segredos do orquestrador da FT Coders no Secret Manager. Spec 0022 do ft-coders."
}

resource "google_secret_manager_secret_iam_member" "ft_coders_orchestrator" {
  for_each = toset(local.ft_coders_orchestrator_secrets)

  project   = var.gcp_project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ft_coders_orchestrator.email}"
}

output "ft_coders_orchestrator_service_account" {
  description = "E-mail da SA do orquestrador da FT Coders (para a criação da chave)."
  value       = google_service_account.ft_coders_orchestrator.email
}
