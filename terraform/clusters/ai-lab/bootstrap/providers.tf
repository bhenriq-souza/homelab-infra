provider "kubernetes" {
  config_path    = pathexpand(var.kubeconfig_path)
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
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
