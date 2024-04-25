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

# Create service account for reading or pulling artifacts in artifact registry
resource "google_service_account" "secret_accessor" {
  account_id   = "${var.environment.prefix}-secret-accessor"
  display_name = "Service Account - ${var.environment.type} secret accessor"

  depends_on = [module.project-services]
}

# Generate service account key
resource "google_service_account_key" "secret_accessor" {
  service_account_id = google_service_account.secret_accessor.name

  depends_on = [google_service_account.secret_accessor]
}