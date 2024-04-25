# Get the current project data
data "google_project" "current" {}

# Enable the used APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = data.google_project.current.project_id
  enable_apis                 = true
  disable_services_on_destroy = false

  activate_apis = [
    "iam.googleapis.com",
  ]
}

variable "service_account_email" {
  type        = string
  description = "Service account to be assigned secret accessor role."
}

variable "secret_name" {
  type        = string
  description = "Secret name to be granted access."
}


resource "google_secret_manager_secret_iam_member" "member" {
  project   = data.google_project.current.project_id
  secret_id = var.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}