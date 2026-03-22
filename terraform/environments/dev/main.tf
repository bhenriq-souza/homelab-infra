module "environment_namespaces" {
  source = "../../modules/environment-namespaces"

  environment = "dev"
  namespaces  = var.namespaces
}
