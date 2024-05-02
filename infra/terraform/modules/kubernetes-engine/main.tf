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

variable "location" {
  type        = string
  description = "Kubernetes Cluster location."
}

variable "environment" {
  type = object({
    type   = string
    prefix = string
  })
  description = "Kubernetes Cluster environment."
}

variable "service_account_email" {
  type        = string
  description = "Kubernetes Engine Service Account."
}

variable "network_name" {
  type        = string
  description = "VPC network name."
}

variable "subnet_name" {
  type        = string
  description = "VPC network subnet name."
}

variable "secondary_range_pods" {
  type = object({
    name       = string
    cidr_range = string
  })
  description = "Subnets secondary ip range for cluster pods."
}

variable "secondary_range_services" {
  type = object({
    name       = string
    cidr_range = string
  })
  description = "Subnets secondary ip range for cluster services."
}

# Giving role to Kubernetes service account

locals {
  cluster = {
    name              = "${var.environment.prefix}-gke-test"
    region            = var.location
    zones             = ["asia-southeast2-a", "asia-southeast2-b"]
    network           = var.network_name
    subnetwork        = var.subnet_name
    ip_range_pods     = var.secondary_range_pods.name
    ip_range_services = var.secondary_range_services.name
    service_account   = var.service_account_email
  }
  node_pools = {
    name            = "default-node-pool"
    machine_type    = "e2-medium"
    node_locations  = "asia-southeast2-a,asia-southeast2-b"
    dist_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    logging_variant = "DEFAULT"
    service_account = var.service_account_email

  }
}



module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = data.google_project.current.project_id
  name                       = local.cluster.name
  region                     = local.cluster.region
  zones                      = local.cluster.zones
  network                    = local.cluster.network
  subnetwork                 = local.cluster.subnetwork
  ip_range_pods              = local.cluster.ip_range_pods
  ip_range_services          = local.cluster.ip_range_services
  service_account            = local.cluster.service_account
  create_service_account     = false
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  deletion_protection        = false
  # grant_registry_access      = true

  node_pools = [
    {
      name                      = local.node_pools.name
      machine_type              = local.node_pools.machine_type
      node_locations            = local.node_pools.node_locations
      min_count                 = 1
      max_count                 = 4
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 100
      disk_type                 = local.node_pools.dist_type
      image_type                = local.node_pools.image_type
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = local.node_pools.logging_variant
      auto_repair               = true
      auto_upgrade              = true
      preemptible               = false
      initial_node_count        = 3
      default_max_pods_per_node = 16
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

output "gke_cluster_name" {
  value       = module.gke.name
  sensitive   = false
  description = "Google Kubernetes Engine Cluster name."
  depends_on  = [module.gke]
}

output "gke_cluster_region" {
  value       = module.gke.region
  sensitive   = false
  description = "Google Kubernetes Engine Cluster region."
  depends_on  = [module.gke]
}

