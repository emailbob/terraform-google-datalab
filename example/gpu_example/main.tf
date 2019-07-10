/**
 * Copyright 2019 Google LLC
 *
 * This software is provided as is, without warranty or representation
 * for any use or purpose. Your use of it is subject to your agreement with Google.
 */

provider "google" {
  project = "${var.project_id}"
  region  = "${var.region}"
}

provider "google-beta" {
  project = "${var.project_id}"
  region  = "${var.region}"
}

/******************************************
  Datalab GPU instance with all optional settings
 *****************************************/
module "datalab" {
  source                    = "../../modules/datalab"
  gpu_type                  = "${var.gpu_type}"
  gpu_count                 = "${var.gpu_count}"
  datalab_gpu_docker_image  = "${var.datalab_gpu_docker_image}"
  name                      = "${var.name}"
  zone                      = "${var.zone}"
  network_name              = "${module.vpc.subnets_names[0]}"
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
