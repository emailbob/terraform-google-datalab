# terraform-google-datalab
A Terraform module for creating Google Cloud DataLab instances.


# Enable APIs
In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

Compute Engine API - compute.googleapis.com


# GPU instance
Not all GPU types are supported in all zones. Go here to check which GPU type and zones are supported https://cloud.google.com/compute/docs/gpus/


The DataLab GPU instance will take a few more minutes to come up since it needs to install the NVIDIA Accelerated Graphics Driver

To verify that the drivers are installed correctly and the instance has the correct number of GPUs run:
`/var/lib/nvidia/bin/nvidia-smi`

# Access the Cloud DataLab UI
gcloud beta compute start-iap-tunnel INSTANCE_NAME 8080 \
  --local-host-port=localhost:8080

From your browser go to http://localhost:8080
