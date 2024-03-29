# Google Cloud DataLab
This modules makes it easy to create and connect to a DataLab instance without needing the datalab command-line tool.  DataLab instances with GPUs are supported.

Use Cloud Datalab to easily explore, visualize, analyze, and transform data using familiar languages, such as Python and SQL, interactively

# Software Dependencies
## Terraform
- [terraform](https://www.terraform.io/downloads.html) 0.11.x
- [terraform-provider-google](https://github.com/terraform-providers/terraform-provider-google) plugin v2.7.0

# Enable APIs
In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

Compute Engine API - compute.googleapis.com

# Service account
The service account for the datalab instances will need the permission `compute.instances.stop` in order to allow the idle timeout option to shutdown the instance.

# GPU instance
Not all GPU types are supported in all zones. Go here to check which GPU type and zones are supported https://cloud.google.com/compute/docs/gpus/


The DataLab GPU instance will take a few more minutes to come up since it needs to install the NVIDIA Accelerated Graphics Driver

To verify that the drivers are installed correctly and the instance has the correct number of GPUs run:
`/var/lib/nvidia/bin/nvidia-smi`

# Access the Cloud DataLab UI
```
gcloud beta compute start-iap-tunnel INSTANCE_NAME 8080 \
  --project PROJECT \
  --zone ZONE \
  --local-host-port=localhost:8080
```

From your browser go to http://localhost:8080
