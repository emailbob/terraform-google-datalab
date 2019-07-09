/**
 * Copyright 2019 Google LLC
 *
 * This software is provided as is, without warranty or representation
 * for any use or purpose. Your use of it is subject to your agreement with Google.
 */

output "datalab_instance_name" {
  value = "${module.datalab.instance_name}"
}

output "datalab_network_name" {
  value = "${module.vpc.network_name}"
}
