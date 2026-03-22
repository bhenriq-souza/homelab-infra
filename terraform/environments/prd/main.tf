module "environment_namespaces" {
  source = "../../modules/environment-namespaces"

  environment = "prd"
  namespaces  = var.namespaces
}
