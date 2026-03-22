locals {
  effective_namespaces = length(var.namespaces) > 0 ? var.namespaces : ["${var.environment}-apps"]
}

resource "kubernetes_namespace_v1" "environment" {
  for_each = toset(local.effective_namespaces)

  metadata {
    name = each.value

    labels = {
      "homelab.io/environment" = var.environment
      "homelab.io/scope"       = "environment"
    }
  }
}
