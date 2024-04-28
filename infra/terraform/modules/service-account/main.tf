data "google_project" "current" {}

# Enable the used APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = data.google_project.current.project_id
  enable_apis                 = true
  disable_services_on_destroy = false

  activate_apis = [
    "secretmanager.googleapis.com",
    "iam.googleapis.com"
  ]
}

locals {
  service_accounts = {
    secret_accessor = {
      account_id = "${var.environment.prefix}-secret-accessor"
      display_name = "Service Account - ${var.environment.type} secret accessor"
    }
    object_admin = {
      account_id   = "${var.environment.prefix}-object-admin"
      display_name = "Service Account - ${var.environment.type} storage object admin."
    }
    kubernetes_engine = {
      account_id = "${var.environment.prefix}-kubernetes-engine"
      display_name = "Service Account - ${var.environment.type} Kubernetes Engine."
    }
  }

}


# Create service account for reading or pulling artifacts in artifact registry
resource "google_service_account" "trydeploy" {
  for_each = local.service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name

  depends_on = [module.project-services]
}

# Generate service account key
resource "google_service_account_key" "trydeploy" {
  for_each = google_service_account.trydeploy

  service_account_id = each.value.name

  depends_on = [google_service_account.trydeploy]
}
