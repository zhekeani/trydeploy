data "google_project" "current" {}

locals {
  region = "asia-southeast2"
  environment = {
    type   = "development"
    prefix = "dev"
  }
}


module "services_config_secret" {
  source               = "./modules/secret"
  secret_source        = 0
  provided_secret_data = var.services_config
  secret_type          = "config-value"
  environment          = local.environment
}

# Create the service accounts
module "service_account" {
  source      = "./modules/service-account"
  environment = local.environment
  location    = local.region
}

# Store service account secret accessor to Secret Manager
module "secret_accessor_private_key_secret" {
  source               = "./modules/secret"
  secret_source        = 1
  provided_secret_data = module.service_account.secret_accessor_private_key
  secret_type          = "service-account-key"
  environment          = local.environment
}


output "sa_secret_accessor_private_key" {
  value       = module.secret_accessor_private_key_secret.secret_data
  sensitive   = true
  description = "sa_secret_accessor_private_key"
}

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
  service_account_email = module.service_account.secret_accessor_svc.email
  secret_name           = module.dummy_secret_version.secret_name
}


output "dummy_secret_version_path" {
  value       = module.dummy_secret_version.secret_path
  sensitive   = false
  description = "Dummy secret version path"
  depends_on  = [module.dummy_secret_version]
}
