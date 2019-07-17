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
  Datalab instance with default settings
 *****************************************/
module "datalab" {
  source             = "../../modules/datalab"
  project_id         = "${var.project_id}"
  name               = "${var.name}"
  zone               = "${var.zone}"
  network_name       = "${module.vpc.subnets_self_links[0]}"
  datalab_user_email = "${var.datalab_user_email}"
}
