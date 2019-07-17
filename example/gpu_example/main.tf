/**
 * Copyright 2019 Google LLC
 *
 * This software is provided as is, without warranty or representation
 * for any use or purpose. Your use of it is subject to your agreement with Google.
 */

provider "google" {
  region  = "${var.region}"
  version = "~> 2.10.0"
}

provider "google-beta" {
  region  = "${var.region}"
  version = "~> 2.10.0"
}

/******************************************
  Datalab GPU instance with all optional settings
 *****************************************/
module "datalab" {
  source                    = "../../modules/datalab"
  project_id                = "${var.project_id}"
  gpu_type                  = "${var.gpu_type}"
  gpu_count                 = "${var.gpu_count}"
  datalab_gpu_docker_image  = "${var.datalab_gpu_docker_image}"
  name                      = "${var.name}"
  zone                      = "${var.zone}"
  service_account           = "${var.service_account}"
  network_name              = "${module.vpc.subnets_self_links[0]}"
  machine_type              = "${var.machine_type}"
  boot_disk_size_gb         = "${var.boot_disk_size_gb}"
  persistant_disk_size_gb   = "${var.persistant_disk_size_gb}"
  datalab_enable_swap       = "${var.datalab_enable_swap}"
  datalab_enable_backup     = "${var.datalab_enable_backup}"
  datalab_console_log_level = "${var.datalab_console_log_level}"
  datalab_user_email        = "${var.datalab_user_email}"
  datalab_idle_timeout      = "${var.datalab_idle_timeout}"
  fluentd_docker_image      = "${var.fluentd_docker_image}"
}
