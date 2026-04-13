# Ajuste para o seu repositorio Git.
gitops_repo_url = "https://github.com/bhenriq-souza/homelab-gitops.git"

# Opcional: pinar a versao do chart para maior reproducibilidade.
argocd_chart_version = "7.7.0"

# Opcional: alterar branch do bootstrap.
gitops_target_revision = "main"

# Path da aplicacao raiz do cluster atual no repositorio GitOps dedicado.
gitops_root_path = "clusters/homelab/bootstrap/root"

# Exposicao do Argo CD para uso diario (sem port-forward recorrente).
argocd_ingress_enabled         = true
argocd_ingress_hostname        = "argocd.homelab.local"
argocd_ingress_class_name      = "traefik"
argocd_ingress_tls_enabled     = true
argocd_ingress_tls_secret_name = "argocd-server-tls"

# Opcional: preencher quando houver cert-manager configurado com ClusterIssuer.
# argocd_ingress_cert_manager_cluster_issuer = "homelab-internal-ca"

# Opcional: apontar para o kubeconfig correto do homelab.
kubeconfig_path = "~/.kube/config-homelab.yaml"

# Opcional: forcar contexto especifico do kubeconfig.
kubeconfig_context = "homelab"

# GCP Secret Manager + ESO + Workload Identity Federation
# Habilite apenas quando o issuer OIDC do K3s estiver acessivel externamente.
gcp_eso_wif_enabled            = true
gcp_project_id                 = "homelab-492918"
gcp_project_number             = "702302784311"
gcp_region                     = "us-central1"
gcp_wif_pool_id                = "homelab-k3s-pool"
gcp_wif_provider_id            = "homelab-k3s-provider"
# Precisa ser um issuer OIDC publico e acessivel pela Google STS.
kubernetes_oidc_issuer_uri     = "https://oidc.homelab.local"
gcp_manage_project_services    = false
gcp_manage_secret_iam_bindings = false

# Lista de segredos permitidos para leitura (criados manualmente no GCP).
gcp_allowed_secret_ids = [
  "homelab-dev-postgres-password",
  "homelab-dev-postgres-url",
  "homelab-prd-postgres-password",
  "homelab-prd-postgres-url"
]
