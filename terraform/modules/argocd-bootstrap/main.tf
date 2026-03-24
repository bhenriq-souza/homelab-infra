resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.argocd_namespace

    labels = {
      "homelab.io/scope" = "cluster-shared"
    }
  }
}

locals {
  argocd_server_ingress_annotations = var.argocd_ingress_cert_manager_cluster_issuer != "" ? {
    "cert-manager.io/cluster-issuer" = var.argocd_ingress_cert_manager_cluster_issuer
  } : {}

  # Baseline tuned for small homelab clusters to reduce Argo CD crashes under sync load.
  default_argocd_helm_values = {
    global = {
      domain = ""
    }
    configs = {
      cm = {
        "timeout.reconciliation"        = "300s"
        "timeout.reconciliation.jitter" = "60s"
      }
      params = {
        "server.insecure" = var.argocd_ingress_enabled ? "true" : "false"
      }
    }
    controller = {
      resources = {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }
    }
    repoServer = {
      resources = {
        requests = {
          cpu    = "250m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }
    }
    server = {
      service = {
        type = "ClusterIP"
      }
      ingress = {
        enabled          = var.argocd_ingress_enabled
        ingressClassName = var.argocd_ingress_class_name
        hostname         = var.argocd_ingress_hostname
        tls              = var.argocd_ingress_tls_enabled
        annotations      = local.argocd_server_ingress_annotations
        extraTls = var.argocd_ingress_tls_enabled && var.argocd_ingress_hostname != "" ? [
          {
            hosts = [var.argocd_ingress_hostname]
            secretName = var.argocd_ingress_tls_secret_name
          }
        ] : []
      }
      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
    applicationSet = {
      resources = {
        requests = {
          cpu    = "50m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }
    }
    redis = {
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "300m"
          memory = "256Mi"
        }
      }
    }
    notifications = {
      enabled = false
    }
    dex = {
      enabled = false
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  version = var.argocd_chart_version

  create_namespace = false
  wait             = true
  atomic           = true
  timeout          = 600

  values = [
    yamlencode(local.default_argocd_helm_values),
    yamlencode(var.argocd_helm_values_override)
  ]
}

resource "kubectl_manifest" "root_application" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.bootstrap_application_name
      namespace = kubernetes_namespace_v1.argocd.metadata[0].name
      labels = {
        "homelab.io/scope" = "cluster-shared"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_target_revision
        path           = var.gitops_root_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace_v1.argocd.metadata[0].name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })

  depends_on = [helm_release.argocd]
}
