# Ajuste para o seu repositorio Git.
gitops_repo_url = "https://github.com/bhenriq-souza/homelab-gitops.git"

# Opcional: pinar a versao do chart para maior reproducibilidade.
argocd_chart_version = "7.7.0"

# Nome do root app do novo cluster.
bootstrap_application_name = "ai-lab-root"

# Opcional: alterar branch do bootstrap.
gitops_target_revision = "main"

# Path da aplicacao raiz do ai-lab no repositorio GitOps dedicado.
gitops_root_path = "clusters/ai-lab/bootstrap/root"

# Mantido desabilitado ate existir uma estrategia clara de exposicao do Argo CD no cluster novo.
argocd_ingress_enabled         = false
argocd_ingress_hostname        = ""
argocd_ingress_class_name      = "traefik"
argocd_ingress_tls_enabled     = false
argocd_ingress_tls_secret_name = "argocd-server-tls"

# Arquivo reservado para o kubeconfig dedicado do ai-lab.
# So criar este arquivo depois que o cluster existir e a API estiver acessivel.
# Referencia operacional: docs/operations/runbooks.md -> Runbook - Criacao do kubeconfig do ai-lab.
kubeconfig_path    = "~/.kube/config-ai-lab.yaml"
kubeconfig_context = "ai-lab"

# Mantido desabilitado ate o cluster ter issuer OIDC, WIF e politica de segredos definidos.
gcp_eso_wif_enabled = false
