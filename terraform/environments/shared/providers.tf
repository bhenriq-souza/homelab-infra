provider "kubernetes" {
  config_path    = pathexpand(var.kubeconfig_path)
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand(var.kubeconfig_path)
    config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
  }
}

provider "kubectl" {
  load_config_file = true
  config_path      = pathexpand(var.kubeconfig_path)
  config_context   = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}
