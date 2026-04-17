resource "google_compute_network" "this" {
  project                         = var.project_id
  name                            = var.network_name
  description                     = var.network_description != "" ? var.network_description : null
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "this" {
  project                  = var.project_id
  name                     = var.subnet_name
  description              = var.subnet_description != "" ? var.subnet_description : null
  region                   = var.region
  ip_cidr_range            = var.subnet_cidr
  network                  = google_compute_network.this.self_link
  private_ip_google_access = var.private_ip_google_access
}