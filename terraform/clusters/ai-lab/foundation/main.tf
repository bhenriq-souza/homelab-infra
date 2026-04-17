locals {
  required_services = toset([
    "compute.googleapis.com",
    "iam.googleapis.com"
  ])

  resolved_network_name   = var.network_name != "" ? var.network_name : "${var.name_prefix}-vpc"
  resolved_subnet_name    = var.subnet_name != "" ? var.subnet_name : "${var.name_prefix}-subnet"
  resolved_instance_name  = var.instance_name != "" ? var.instance_name : "${var.name_prefix}-vm"
  resolved_data_disk_name = "${local.resolved_instance_name}-data"

  common_labels = merge({
    workload    = "ai-lab"
    environment = var.environment_name
    managed_by  = "terraform"
  }, var.labels)

  vm_network_tags = distinct(concat(var.instance_network_tags, ["${var.name_prefix}-vm"]))

  service_ingress_rules_by_name = {
    for rule in var.service_ingress_rules : rule.name => rule
  }
}

resource "google_project_service" "required" {
  for_each = var.manage_project_services ? local.required_services : toset([])

  project = var.project_id
  service = each.value
}

module "network_vpc" {
  source = "../../../modules/network-vpc"

  project_id               = var.project_id
  network_name             = local.resolved_network_name
  network_description      = "VPC dedicada da fundacao do ai-lab na GCP."
  region                   = var.region
  subnet_name              = local.resolved_subnet_name
  subnet_description       = "Subnet principal do ai-lab na GCP."
  subnet_cidr              = var.subnet_cidr
  private_ip_google_access = var.private_ip_google_access

  depends_on = [google_project_service.required]
}

resource "google_service_account" "vm" {
  project      = var.project_id
  account_id   = var.instance_service_account_id
  display_name = "AI Lab foundation VM"
  description  = "Service account dedicada a VM base do ai-lab."
}

resource "google_project_iam_member" "vm_roles" {
  for_each = toset(var.instance_service_account_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm.email}"
}

resource "google_compute_address" "vm_public_ip" {
  count = var.assign_public_ip ? 1 : 0

  project      = var.project_id
  name         = "${var.name_prefix}-public-ip"
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.required]
}

resource "google_compute_firewall" "ssh_admin" {
  project       = var.project_id
  name          = "${var.name_prefix}-allow-ssh-admin"
  network       = module.network_vpc.network_self_link
  description   = "Permite SSH administrativo apenas a partir dos CIDRs autorizados."
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = var.admin_source_ranges
  target_tags   = local.vm_network_tags

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "internal_subnet" {
  project       = var.project_id
  name          = "${var.name_prefix}-allow-internal-subnet"
  network       = module.network_vpc.network_self_link
  description   = "Permite trafego interno basico dentro da subnet do ai-lab."
  direction     = "INGRESS"
  priority      = 1100
  source_ranges = [var.subnet_cidr]
  target_tags   = local.vm_network_tags

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "future_k3s_api" {
  count = var.enable_future_k3s_api_firewall ? 1 : 0

  project       = var.project_id
  name          = "${var.name_prefix}-allow-k3s-api-admin"
  network       = module.network_vpc.network_self_link
  description   = "Reserva a liberacao da porta 6443 para a futura instalacao do K3s."
  direction     = "INGRESS"
  priority      = 1200
  source_ranges = var.admin_source_ranges
  target_tags   = local.vm_network_tags

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
}

resource "google_compute_firewall" "service_ingress" {
  for_each = local.service_ingress_rules_by_name

  project       = var.project_id
  name          = "${var.name_prefix}-${each.key}"
  network       = module.network_vpc.network_self_link
  description   = try(each.value.description, "Permite acesso controlado a servicos publicados pela VM do ai-lab.")
  direction     = "INGRESS"
  priority      = try(each.value.priority, 1150)
  source_ranges = each.value.source_ranges
  target_tags   = local.vm_network_tags

  allow {
    protocol = try(each.value.protocol, "tcp")
    ports    = try(each.value.ports, null)
  }
}

module "compute_vm" {
  source = "../../../modules/compute-vm"

  project_id                  = var.project_id
  instance_name               = local.resolved_instance_name
  zone                        = var.zone
  machine_type                = var.machine_type
  subnetwork_self_link        = module.network_vpc.subnet_self_link
  assign_public_ip            = var.assign_public_ip
  public_ip_address           = var.assign_public_ip ? google_compute_address.vm_public_ip[0].address : null
  tags                        = local.vm_network_tags
  labels                      = local.common_labels
  boot_disk_image             = var.boot_disk_image
  boot_disk_size_gb           = var.boot_disk_size_gb
  boot_disk_type              = var.boot_disk_type
  data_disk_name              = local.resolved_data_disk_name
  data_disk_size_gb           = var.data_disk_size_gb
  data_disk_type              = var.data_disk_type
  guest_accelerator_type      = var.guest_accelerator_type
  guest_accelerator_count     = var.guest_accelerator_count
  service_account_email       = google_service_account.vm.email
  metadata                    = var.instance_metadata
  ssh_public_keys             = var.instance_ssh_public_keys
  startup_script              = var.instance_startup_script
  instance_provisioning_model = var.instance_provisioning_model
  instance_termination_action = var.instance_termination_action

  depends_on = [
    google_project_service.required,
    google_project_iam_member.vm_roles
  ]
}