locals {
  instance_metadata = merge(
    var.metadata,
    var.enable_serial_port ? { "serial-port-enable" = "TRUE" } : {},
    length(var.ssh_public_keys) > 0 ? { "ssh-keys" = join("\n", var.ssh_public_keys) } : {}
  )

  has_guest_accelerator          = var.guest_accelerator_count > 0
  accelerator_optimized_family   = can(regex("^(g2|a2|a3)-", var.machine_type))
  requires_terminate_maintenance = local.has_guest_accelerator || local.accelerator_optimized_family
}

resource "google_compute_disk" "data" {
  count = var.data_disk_size_gb > 0 ? 1 : 0

  project = var.project_id
  name    = var.data_disk_name != "" ? var.data_disk_name : "${var.instance_name}-data"
  zone    = var.zone
  type    = var.data_disk_type
  size    = var.data_disk_size_gb
}

resource "google_compute_instance" "this" {
  project                   = var.project_id
  name                      = var.instance_name
  zone                      = var.zone
  machine_type              = var.machine_type
  can_ip_forward            = var.can_ip_forward
  allow_stopping_for_update = true
  desired_status            = var.desired_status
  tags                      = var.tags
  labels                    = var.labels

  boot_disk {
    auto_delete = true

    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    subnetwork = var.subnetwork_self_link

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [var.public_ip_address] : []

      content {
        nat_ip = access_config.value
      }
    }
  }

  dynamic "attached_disk" {
    for_each = google_compute_disk.data

    content {
      source      = attached_disk.value.id
      device_name = attached_disk.value.name
      mode        = "READ_WRITE"
    }
  }

  dynamic "guest_accelerator" {
    for_each = local.has_guest_accelerator ? [1] : []

    content {
      type  = var.guest_accelerator_type
      count = var.guest_accelerator_count
    }
  }

  dynamic "service_account" {
    for_each = var.service_account_email != null ? [var.service_account_email] : []

    content {
      email  = service_account.value
      scopes = var.service_account_scopes
    }
  }

  metadata                = local.instance_metadata
  metadata_startup_script = var.startup_script != "" ? var.startup_script : null

  scheduling {
    automatic_restart           = var.instance_provisioning_model == "SPOT" ? false : var.automatic_restart
    on_host_maintenance         = var.instance_provisioning_model == "SPOT" || local.requires_terminate_maintenance ? "TERMINATE" : var.on_host_maintenance
    preemptible                 = var.instance_provisioning_model == "SPOT"
    provisioning_model          = var.instance_provisioning_model
    instance_termination_action = var.instance_provisioning_model == "SPOT" ? var.instance_termination_action : null
  }

  shielded_instance_config {
    enable_secure_boot          = var.shielded_secure_boot
    enable_vtpm                 = var.shielded_vtpm
    enable_integrity_monitoring = var.shielded_integrity_monitoring
  }
}