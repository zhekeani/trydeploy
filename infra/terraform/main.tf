data "google_project" "current" {}

locals {
  region = "asia-southeast2"
  environment = {
    type   = "development"
    prefix = "dev"
  }
  project_name = "trydeploy"
}

locals {
  storage_bucket_name = "zhekeani-${local.project_name}"
}

# Create the service accounts
module "service_account" {
  source      = "./modules/service-account"
  environment = local.environment
  location    = local.region
}

# Create storage bucket
module "storage_bucket" {
  source                = "./modules/storage-bucket"
  location              = local.region
  environment           = local.environment
  bucket_name           = local.storage_bucket_name
  object_admin_sa_email = module.service_account.sa_properties["object_admin"].email
}

# Create Artifact Registry Repositories
module "artifact_registry" {
  source      = "./modules/artifact-registry"
  location    = local.region
  environment = local.environment
}


# Create and store secret for Services Config
module "services_config_secret" {
  source               = "./modules/secret"
  secret_source        = 0
  provided_secret_data = var.services_config
  secret_type          = "config-value"
  environment          = local.environment
}


# Store service account secret accessor to Secret Manager
module "sa_private_key_secrets" {
  for_each = module.service_account.sa_private_keys

  source               = "./modules/secret"
  secret_source        = 1
  provided_secret_data = each.value
  secret_type          = "${replace(each.key, "_", "-")}-sa-key"
  environment          = local.environment
}

# Create dummy secret version
module "dummy_secret_version" {
  source               = "./modules/secret"
  secret_source        = 1
  provided_secret_data = "dummy_secret_version"
  secret_type          = "dummy-secret"
  environment          = local.environment
}

# Assign secret accessor role to service account
module "secret_accessor_iam_member_dummy_secret" {
  source                = "./modules/iam-member/secret-manager/secret-accessor"
  service_account_email = module.service_account.sa_properties["secret_accessor"].email
  secret_name           = module.dummy_secret_version.secret_name
}


# Assign secret accessor role to service account
module "secret_accessor_iam_member_sa_keys" {
  for_each = module.sa_private_key_secrets

  source                = "./modules/iam-member/secret-manager/secret-accessor"
  service_account_email = module.service_account.sa_properties["secret_accessor"].email
  secret_name           = each.value.secret_name

  depends_on = [module.sa_private_key_secrets]
}

# compute VPC for GKE
module "compute_vpc" {
  source      = "./modules/vpc"
  location    = local.region
  environment = local.environment
}

locals {
  cluster_region   = "asia-southeast1"
  gke_network_name = module.compute_vpc.network.name
  gke_subnet_name  = module.compute_vpc.subnets.names[0]

  gke_secondary_range_pods = {
    name       = module.compute_vpc.subnets.secondary_ranges[0][0].range_name
    cidr_range = module.compute_vpc.subnets.secondary_ranges[0][0].ip_cidr_range
  }
  gke_secondary_range_services = {
    name       = module.compute_vpc.subnets.secondary_ranges[0][1].range_name
    cidr_range = module.compute_vpc.subnets.secondary_ranges[0][1].ip_cidr_range
  }
}


data "google_secret_manager_secrets" "all" {
}

module "kubernetes_engine_sa_iam" {
  source                = "./modules/iam-member/kubernetes-engine"
  location              = local.region
  service_account_email = module.service_account.sa_properties["kubernetes_engine"].email
  secrets_name          = [for secret in data.google_secret_manager_secrets.all.secrets : secret.name]
  bucket_name           = module.storage_bucket.bucket_name
  repositories_name     = [for repository in values(module.artifact_registry.nestjs_repositories_name) : repository.repository_name]
}

# Create kubernetes engine
module "kubernetes_engine" {
  source                   = "./modules/kubernetes-engine"
  location                 = local.region
  environment              = local.environment
  service_account_email    = module.service_account.sa_properties["kubernetes_engine"].email
  network_name             = local.gke_network_name
  subnet_name              = local.gke_subnet_name
  secondary_range_pods     = local.gke_secondary_range_pods
  secondary_range_services = local.gke_secondary_range_services
}

