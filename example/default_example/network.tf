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
  version      = "0.8.0"
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
  provider       = "google-beta"
  name           = "${module.vpc.network_name}-allow-iap"
  project        = "${var.project_id}"
  network        = "${module.vpc.network_name}"
  description    = "Allow ssh iap tunnel to Datalab instance"
  direction      = "INGRESS"
  disabled       = false
  priority       = "65534"
  enable_logging = true
  source_ranges  = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["datalab"]
}

/******************************************
  Firewall rule to allow access to the web UI
 *****************************************/
resource "google_compute_firewall" "allow_web" {
  name          = "${module.vpc.network_name}-allow-web"
  project       = "${var.project_id}"
  network       = "${module.vpc.network_name}"
  description   = "Allow access to Datalab web UI"
  direction     = "INGRESS"
  disabled      = false
  priority      = "1000"
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  target_tags = ["datalab"]
}

/******************************************
  Adding Cloud NAT
  This is needed so datalab can access the notebook at
  https://github.com/googledatalab/notebooks.git
 *****************************************/
resource "google_compute_router" "router" {
  name    = "${local.network_name}-router"
  region  = "${var.region}"
  network = "${module.vpc.network_self_link}"

  bgp {
    asn = 64514
  }

  project = "${var.project_id}"
}

/******************************************
  Adding Cloud Router
 *****************************************/
resource "google_compute_router_nat" "nat" {
  name                               = "${local.network_name}-nat"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = "${var.project_id}"
}
