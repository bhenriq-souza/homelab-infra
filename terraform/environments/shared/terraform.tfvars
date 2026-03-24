# Ajuste para o seu repositorio Git.
gitops_repo_url = "https://github.com/bhenriq-souza/homelab-infra.git"

# Opcional: pinar a versao do chart para maior reproducibilidade.
argocd_chart_version = "7.7.0"

# Opcional: alterar branch do bootstrap.
gitops_target_revision = "main"

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
kubeconfig_context = "default"
