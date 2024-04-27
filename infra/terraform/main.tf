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
module storage_bucket {
  source = "./modules/storage-bucket"
  location = local.region
  environment = local.environment
  bucket_name = local.storage_bucket_name
  object_admin_sa_email = module.service_account.sa_properties["object_admin"].email
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
module "secret_accessor_iam_member" {
  source                = "./modules/iam-member/secret-manager/secret-accessor"
  service_account_email = module.service_account.sa_properties["secret_accessor"].email
  secret_name           = module.dummy_secret_version.secret_name
}


