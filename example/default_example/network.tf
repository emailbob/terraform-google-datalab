/**
 * Copyright 2019 Google LLC
 *
 * This software is provided as is, without warranty or representation
 * for any use or purpose. Your use of it is subject to your agreement with Google.
 */

locals {
  network_name = "${var.network_name}-default"
  subnet_name  = "${local.network_name}-subnet"
  subnet_ip    = "10.10.10.0/24"
}

/******************************************
  Create VPC
 *****************************************/
module "vpc" {
  source       = "terraform-google-modules/network/google"
  project_id   = "${var.project_id}"
  network_name = "${local.network_name}"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.subnet_name}"
      subnet_ip             = "${local.subnet_ip}"
      subnet_region         = "${var.region}"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
  ]

  secondary_ranges = {
    "${local.subnet_name}" = []
  }
}

/******************************************
  Firewall rule to allow tunnel-through-iap
 *****************************************/
resource "google_compute_firewall" "allow_iap" {
  provider    = "google-beta"
  name        = "${module.vpc.network_name}-allow-iap"
  network     = "${module.vpc.network_name}"
  description = "Allow ssh iap tunnel to Datalab instance"
  project     = "${var.project_id}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"

  priority      = "65534"
  source_ranges = ["35.235.240.0/20"]

  enable_logging = true
}
