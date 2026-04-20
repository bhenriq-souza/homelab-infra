variable "kubeconfig_path" {
  description = "Caminho do kubeconfig usado para conectar ao cluster K3s."
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Contexto do kubeconfig. Quando vazio, usa o contexto atual."
  type        = string
  default     = ""
}

variable "argocd_namespace" {
  description = "Namespace compartilhado para o Argo CD."
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Versao do chart argo-cd. Use null para seguir a versao mais recente do repositorio Helm."
  type        = string
  default     = null
  nullable    = true
}

variable "argocd_helm_values_override" {
  description = "Valores extras/override para o chart argo-cd no ambiente shared."
  type        = any
  default     = {}
}

variable "argocd_ingress_enabled" {
  description = "Habilita Ingress para acesso ao Argo CD no ambiente shared."
  type        = bool
  default     = false
}

variable "argocd_ingress_hostname" {
  description = "Hostname do Ingress do Argo CD no ambiente shared."
  type        = string
  default     = ""
}

variable "argocd_ingress_class_name" {
  description = "IngressClass para o Ingress do Argo CD."
  type        = string
  default     = "traefik"
}

variable "argocd_ingress_tls_enabled" {
  description = "Habilita TLS no Ingress do Argo CD."
  type        = bool
  default     = true
}

variable "argocd_ingress_tls_secret_name" {
  description = "Nome do secret TLS do Ingress do Argo CD."
  type        = string
  default     = "argocd-server-tls"
}

variable "argocd_ingress_cert_manager_cluster_issuer" {
  description = "ClusterIssuer do cert-manager para o certificado TLS do Argo CD."
  type        = string
  default     = ""
}

variable "gitops_repo_url" {
  description = "URL do repositorio Git que contem a arvore GitOps consumida pelo Argo CD."
  type        = string
}

variable "gitops_target_revision" {
  description = "Branch, tag ou commit para o bootstrap GitOps."
  type        = string
  default     = "main"
}

variable "gitops_root_path" {
  description = "Path no repositorio GitOps para a aplicacao raiz do cluster."
  type        = string
  default     = "clusters/homelab/bootstrap/root"
}

variable "gcp_eso_wif_enabled" {
  description = "Habilita infraestrutura GCP para ESO com Workload Identity Federation."
  type        = bool
  default     = false
}

variable "gcp_project_id" {
  description = "Project ID GCP que contem os segredos."
  type        = string
  default     = "homelab-492918"
}

variable "gcp_project_number" {
  description = "Project number GCP usado em principal:// e audience do WIF."
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "Regiao default para provider google."
  type        = string
  default     = "us-central1"
}

variable "gcp_wif_pool_id" {
  description = "ID do workload identity pool para o cluster K3s."
  type        = string
  default     = "homelab-k3s-pool"
}

variable "gcp_wif_provider_id" {
  description = "ID do workload identity provider OIDC para o cluster K3s."
  type        = string
  default     = "homelab-k3s-provider"
}

variable "kubernetes_oidc_issuer_uri" {
  description = "Issuer URI OIDC do K3s, acessivel pela Google STS (discovery + JWKS)."
  type        = string
  default     = ""
}

variable "gcp_allowed_kubernetes_service_accounts" {
  description = "SAs Kubernetes que podem federar para acesso aos secrets."
  type = list(object({
    namespace = string
    name      = string
  }))
  default = [
    {
      namespace = "external-secrets"
      name      = "eso-gcp-dev"
    },
    {
      namespace = "external-secrets"
      name      = "eso-gcp-prd"
    }
  ]
}

variable "gcp_allowed_secret_ids" {
  description = "Lista de Secret IDs que o ESO pode ler no Secret Manager."
  type        = list(string)
  default     = []
}

variable "gcp_use_service_account_impersonation" {
  description = "Usa SA GCP intermediaria para acesso aos secrets (avancado). Padrao usa principal federado direto."
  type        = bool
  default     = false
}

variable "gcp_eso_service_account_id" {
  description = "Account ID da SA GCP usada pelo ESO quando impersonation estiver ativa."
  type        = string
  default     = "eso-secrets-reader"
}

variable "gcp_wif_attribute_condition" {
  description = "Condicao CEL opcional no provider WIF. Vazio usa condicao baseada nas SAs permitidas."
  type        = string
  default     = ""
}

variable "gcp_manage_project_services" {
  description = "Quando true, Terraform gerencia habilitacao das APIs GCP necessarias."
  type        = bool
  default     = true
}

variable "gcp_manage_secret_iam_bindings" {
  description = "Quando true, Terraform gerencia IAM dos segredos no Secret Manager."
  type        = bool
  default     = true
}

# --- Artifact Registry ---

variable "artifact_registry_enabled" {
  description = "Habilita criacao do Artifact Registry para imagens Docker."
  type        = bool
  default     = false
}

variable "artifact_registry_repository_id" {
  description = "ID do repositorio no Artifact Registry."
  type        = string
  default     = "homelab-apps"
}

variable "artifact_registry_create_reader_sa" {
  description = "Cria SA de leitura e armazena a chave no Secret Manager para image pull."
  type        = bool
  default     = true
}

variable "artifact_registry_reader_sa_id" {
  description = "Account ID da SA de leitura do registry."
  type        = string
  default     = "ar-reader"
}

variable "artifact_registry_reader_key_secret_id" {
  description = "Secret ID no Secret Manager para a chave da SA de leitura."
  type        = string
  default     = "homelab-ar-reader-sa-key"
}

# --- GitHub Actions WIF ---

variable "github_wif_enabled" {
  description = "Habilita WIF para GitHub Actions."
  type        = bool
  default     = false
}

variable "github_wif_pool_id" {
  description = "ID do Workload Identity Pool para GitHub Actions."
  type        = string
  default     = "github-actions-pool"
}

variable "github_wif_provider_id" {
  description = "ID do Workload Identity Provider OIDC para GitHub Actions."
  type        = string
  default     = "github-actions-provider"
}

variable "github_organization" {
  description = "Owner/organization do GitHub."
  type        = string
  default     = "bhenriq-souza"
}

variable "github_allowed_repositories" {
  description = "Lista de repositorios GitHub autorizados para CI (formato: owner/repo)."
  type        = list(string)
  default     = []
}

variable "github_dev_branches" {
  description = "Branches que representam o ambiente dev."
  type        = list(string)
  default     = ["develop"]
}

variable "github_prd_branches" {
  description = "Branches que representam o ambiente prd."
  type        = list(string)
  default     = ["main"]
}

variable "github_ci_service_account_id" {
  description = "Account ID da SA GCP usada pelo GitHub Actions CI."
  type        = string
  default     = "github-actions-ci"
}

# --- Artifact Registry npm ---

variable "artifact_registry_npm_enabled" {
  description = "Habilita criacao do Artifact Registry formato npm para pacotes TypeScript."
  type        = bool
  default     = false
}

variable "artifact_registry_npm_repository_id" {
  description = "ID do repositorio npm no Artifact Registry."
  type        = string
  default     = "typescript-packages-dev"
}

variable "artifact_registry_npm_description" {
  description = "Descricao do repositorio npm no Artifact Registry."
  type        = string
  default     = "Registry npm para artefatos dev de PRs do monorepo typescript-common-packages"
}

variable "artifact_registry_npm_dev_retention_days" {
  description = "Dias para reter artefatos dev antes de cleanup."
  type        = number
  default     = 30
}

variable "artifact_registry_npm_dev_tag_prefixes" {
  description = "Prefixos de dist-tag npm considerados dev para cleanup."
  type        = list(string)
  default     = ["dev"]
}

variable "artifact_registry_npm_keep_minimum_versions" {
  description = "Numero minimo de versoes a manter por pacote. Null desabilita."
  type        = number
  default     = null
  nullable    = true
}

# --- GCS Nx Cache ---

variable "gcs_nx_cache_enabled" {
  description = "Habilita criacao do bucket GCS para cache remoto do Nx."
  type        = bool
  default     = false
}

variable "gcs_nx_cache_bucket_name" {
  description = "Nome do bucket GCS para cache Nx."
  type        = string
  default     = "typescript-nx-cache"
}

variable "gcs_nx_cache_lifecycle_age_days" {
  description = "Dias para reter objetos de cache antes de deletar."
  type        = number
  default     = 90
}
