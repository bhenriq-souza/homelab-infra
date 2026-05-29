# Secrets do projeto Techlead Joe no GCP Secret Manager.
# Os valores devem ser populados manualmente via gcloud ou console após o apply.
# Acesso pelo ESO é garantido pelo binding de projeto em homelab-secrets-issuer-dev/prd.

locals {
  tj_secrets_dev = [
    "tj-postgres-host",
    "tj-postgres-db",
    "tj-postgres-user",
    "tj-postgres-password",
    "tj-ollama-base-url",
  ]
}

resource "google_secret_manager_secret" "tj_dev" {
  for_each = toset(local.tj_secrets_dev)

  project   = var.gcp_project_id
  secret_id = each.value

  labels = {
    project = "techlead-joe"
    env     = "dev"
  }

  replication {
    auto {}
  }
}
