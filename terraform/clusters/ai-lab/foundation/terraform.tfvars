project_id = "homelab-492918"

region = "us-central1"
zone   = "us-central1-a"

name_prefix      = "ai-lab"
environment_name = "gcp-lab"

admin_source_ranges = [
  "177.76.206.120/32"
]

subnet_cidr = "10.60.0.0/24"

# g2-standard-8 inclui 1 NVIDIA L4 integrada ao machine type; nao precisa de guest_accelerator.
machine_type                = "g2-standard-8"
instance_provisioning_model = "STANDARD"

boot_disk_size_gb       = 150
data_disk_size_gb       = 0

# Manter false nesta etapa; a abertura da API do K3s fica para a fase seguinte.
enable_future_k3s_api_firewall = false

service_ingress_rules = [
  {
    name          = "allow-ollama-homelab"
    description   = "Permite acesso do homelab ao endpoint do Ollama publicado na VM."
    source_ranges = ["177.76.206.120/32"]
    protocol      = "tcp"
    ports         = ["11434"]
  }
]

instance_service_account_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter"
]

labels = {
  workload    = "ai-lab"
  environment = "gcp-lab"
}