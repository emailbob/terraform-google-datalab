/**
 * Copyright 2019 Google LLC
 *
 * This software is provided as is, without warranty or representation
 * for any use or purpose. Your use of it is subject to your agreement with Google.
 */

locals {
  datalab_partial      = "${data.template_file.datalab_partial.rendered}"
  datalab_gpu_partial  = "${data.template_file.datalab_gpu_partial.rendered}"
  datalab_docker_image = "${var.gpu_count == "0" ? var.datalab_docker_image : var.datalab_gpu_docker_image}"
}

/***********************************************
  Template for the startup script
 ***********************************************/
data "template_file" "startup_script" {
  template = "${file("${path.module}/templates/startup_script.tpl")}"

  vars {
    datalab_docker_image = "${local.datalab_docker_image}"
    disk_name            = "${var.name}-pd"
    datalab_enable_swap  = "${var.datalab_enable_swap}"
  }
}

/***********************************************
  Partial template that goes into cloud config for default instances
 ***********************************************/
data "template_file" "datalab_partial" {
  template = "${file("${path.module}/templates/datalab_partial.tpl")}"

  vars {
    datalab_docker_image      = "${local.datalab_docker_image}"
    datalab_enable_backup     = "${var.datalab_enable_backup}"
    datalab_console_log_level = "${var.datalab_console_log_level}"
    datalab_user_email        = "${var.datalab_user_email}"
    datalab_idle_timeout      = "${var.datalab_idle_timeout}"
  }
}

/***********************************************
  Partial template that goes into cloud config for GPU instances
 ***********************************************/
data "template_file" "datalab_gpu_partial" {
  template = "${file("${path.module}/templates/datalab_gpu_partial.tpl")}"

  vars {
    datalab_docker_image      = "${local.datalab_docker_image}"
    datalab_enable_backup     = "${var.datalab_enable_backup}"
    datalab_console_log_level = "${var.datalab_console_log_level}"
    datalab_user_email        = "${var.datalab_user_email}"
    datalab_idle_timeout      = "${var.datalab_idle_timeout}"
    gpu_device                = "${lookup(var.gpu_device_map, "gpu_device_${var.gpu_count}")}"
  }
}

/***********************************************
  Main cloud config template
 ***********************************************/
data "template_file" "cloud_config" {
  template = "${file("${path.module}/templates/cloud_config.tpl")}"

  vars {
    datalab_partial      = "${var.gpu_count == "0" ? local.datalab_partial : ""}"
    datalab_gpu_partial  = "${var.gpu_count == "0" ? "" : local.datalab_gpu_partial}"
    fluentd_docker_image = "${var.fluentd_docker_image}"
    systemctl_gpu        = "${var.gpu_count == "0" ? "" : var.systemctl_gpu}"
  }
}

/***********************************************
  Create GCE instance
 ***********************************************/
resource "google_compute_instance" "main" {
  name         = "${var.name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  tags = ["datalab"]

  labels {
    role      = "datalab"
    use_gpu   = "${var.gpu_count == "0" ? "false" : "true"}"
    gpu_count = "${var.gpu_count}"
  }

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = "${var.boot_disk_size_gb}"
    }
  }

  attached_disk {
    source      = "${google_compute_disk.main.name}"
    device_name = "${var.name}-pd"
  }

  network_interface {
    subnetwork = "${var.network_name}"
  }

  metadata = {
    enable-oslogin = "TRUE"
    for-user       = "${var.datalab_user_email}"
    user-data      = "${data.template_file.cloud_config.rendered}"
  }

  metadata_startup_script = "${data.template_file.startup_script.rendered}"

  service_account {
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "${var.gpu_count == "0" ? "MIGRATE" : "TERMINATE"}"
    preemptible         = false
  }

  guest_accelerator {
    count = "${var.gpu_count == "0" ? 0 : var.gpu_count}"
    type  = "${var.gpu_type}"
  }
}

/******************************************
  Create the persistent data disk
  Does not create a new disk if an existing_disk_name is set
 *****************************************/
resource "google_compute_disk" "main" {
  count = "${var.existing_disk_name == "" ? 1 : 0}"
  name  = "${var.name}-pd"
  type  = "pd-ssd"
  size  = "${var.persistant_disk_size_gb}"
  zone  = "${var.zone}"
}
