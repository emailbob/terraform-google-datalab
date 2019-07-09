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
  Datalab instance with default settings
 *****************************************/
module "datalab" {
  source             = "../../modules/datalab"
  name               = "${var.name}"
  zone               = "${var.zone}"
  network_name       = "${module.vpc.subnets_names[0]}"
  datalab_user_email = "${var.datalab_user_email}"
}
