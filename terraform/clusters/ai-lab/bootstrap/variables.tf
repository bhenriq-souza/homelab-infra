variable "kubeconfig_path" {
  description = "Caminho do kubeconfig usado para conectar ao cluster ai-lab."
  type        = string
  default     = "~/.kube/config-ai-lab.yaml"
}

variable "kubeconfig_context" {
  description = "Contexto do kubeconfig para o cluster ai-lab. Quando vazio, usa o contexto atual."
  type        = string
  default     = "ai-lab"
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

variable "bootstrap_application_name" {
  description = "Nome da aplicacao raiz de bootstrap do ai-lab."
  type        = string
  default     = "ai-lab-root"
}

variable "argocd_helm_values_override" {
  description = "Valores extras ou override para o chart argo-cd no ai-lab."
  type        = any
  default     = {}
}

variable "argocd_ingress_enabled" {
  description = "Habilita Ingress para acesso ao Argo CD no ai-lab."
  type        = bool
  default     = false
}

variable "argocd_ingress_hostname" {
  description = "Hostname do Ingress do Argo CD no ai-lab."
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
  default     = false
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
  description = "Path no repositorio GitOps para a aplicacao raiz do cluster ai-lab."
  type        = string
  default     = "clusters/ai-lab/bootstrap/root"
}

variable "gcp_eso_wif_enabled" {
  description = "Habilita infraestrutura GCP para ESO com Workload Identity Federation no ai-lab."
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
  description = "ID do workload identity pool para o ai-lab."
  type        = string
  default     = "ai-lab-pool"
}

variable "gcp_wif_provider_id" {
  description = "ID do workload identity provider OIDC para o ai-lab."
  type        = string
  default     = "ai-lab-provider"
}

variable "kubernetes_oidc_issuer_uri" {
  description = "Issuer URI OIDC do cluster, acessivel pela Google STS (discovery + JWKS)."
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
  description = "Usa SA GCP intermediaria para acesso aos secrets. Padrao usa principal federado direto."
  type        = bool
  default     = false
}

variable "gcp_eso_service_account_id" {
  description = "Account ID da SA GCP usada pelo ESO quando impersonation estiver ativa."
  type        = string
  default     = "ai-lab-eso-secrets-reader"
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
