data "google_client_config" "default" {}

data "google_project" "current" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# Enable the used APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = data.google_project.current.project_id
  enable_apis                 = true
  disable_services_on_destroy = false

  activate_apis = [
    "container.googleapis.com",
    "compute.googleapis.com"
  ]
}

variable location {
  type        = string
  description = "Kubernetes Cluster location."
}

variable environment {
  type        = object({
    type = string
    prefix = string
  })
  description = "Kubernetes Cluster environment."
}

variable service_account_email {
  type        = string
  description = "Kubernetes Engine Service Account."
}


# Giving role to Kubernetes service account



locals {
  cluster = {
    name = "${var.environment.prefix}-gke-test"
    region = var.location
    zones = ["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"]
    network = "default"
    subnetwork = "asia-southeast2-01"
    ip_range_pods = "asia-southeast2-gke-01-pods"
    ip_range_services = "asia-southeast2-gke-01-services"
  }
  node_pools = {
    name = "default-node-pool"
    machine_type = "e2-medium"
    node_locations = "asia-southeast2-a, asia-southeast2-b, asia-southeast2-c"
    dist_type = "pd-standard"
    image_type = "COS_CONTAINERD"
    logging_variant = "DEFAULT"
    service_account = var.service_account_email

  }
}



# module "gke" {
#   source                     = "terraform-google-modules/kubernetes-engine/google"
#   project_id                 = "<PROJECT ID>"
#   name                       = "gke-test-1"
#   region                     = var.location
#   zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
#   network                    = "vpc-01"
#   subnetwork                 = "us-central1-01"
#   ip_range_pods              = "us-central1-01-gke-01-pods"
#   ip_range_services          = "us-central1-01-gke-01-services"
#   http_load_balancing        = false
#   network_policy             = false
#   horizontal_pod_autoscaling = true
#   filestore_csi_driver       = false

#   node_pools = [
#     {
#       name                      = "default-node-pool"
#       machine_type              = "e2-medium"
#       node_locations            = "us-central1-b,us-central1-c"
#       min_count                 = 1
#       max_count                 = 100
#       local_ssd_count           = 0
#       spot                      = false
#       disk_size_gb              = 100
#       disk_type                 = "pd-standard"
#       image_type                = "COS_CONTAINERD"
#       enable_gcfs               = false
#       enable_gvnic              = false
#       logging_variant           = "DEFAULT"
#       auto_repair               = true
#       auto_upgrade              = true
#       service_account           = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
#       preemptible               = false
#       initial_node_count        = 80
#     },
#   ]

#   node_pools_oauth_scopes = {
#     all = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]
#   }

#   node_pools_labels = {
#     all = {}

#     default-node-pool = {
#       default-node-pool = true
#     }
#   }

#   node_pools_metadata = {
#     all = {}

#     default-node-pool = {
#       node-pool-metadata-custom-value = "my-node-pool"
#     }
#   }

#   node_pools_taints = {
#     all = []

#     default-node-pool = [
#       {
#         key    = "default-node-pool"
#         value  = true
#         effect = "PREFER_NO_SCHEDULE"
#       },
#     ]
#   }

#   node_pools_tags = {
#     all = []

#     default-node-pool = [
#       "default-node-pool",
#     ]
#   }
# }