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
    "compute.googleapis.com"
  ]
}


locals {
  network_name = "${var.environment.prefix}-compute-vpc"

  subnets = [
    {
      subnet_name   = "${var.environment.prefix}-asia-southeast2"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.location
    }
  ]

  secondary_ranges = {
    "${local.subnets[0].subnet_name}" = [
      {
        range_name    = "${var.environment.prefix}-asia-southeast2-pods"
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = "${var.environment.prefix}-asia-southeast2-services"
        ip_cidr_range = "10.30.0.0/16"
      }
    ]
  }
}



module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.1"

  project_id   = data.google_project.current.project_id
  network_name = local.network_name
  routing_mode = "GLOBAL"

  depends_on = [module.project-services]

  subnets = local.subnets

  secondary_ranges = local.secondary_ranges
}

locals {
  created_network = {
    name = module.vpc.network_name
  }
  created_subnets = {
    names            = module.vpc.subnets_names
    regions          = module.vpc.subnets_regions
    secondary_ranges = module.vpc.subnets_secondary_ranges
  }
}


output "network" {
  value       = local.created_network
  sensitive   = false
  description = "Created VPC network."
  depends_on  = [module.vpc]
}

output "subnets" {
  value       = local.created_subnets
  sensitive   = false
  description = "Subnet created inside the VPC network."
  depends_on  = [module.vpc]
}
