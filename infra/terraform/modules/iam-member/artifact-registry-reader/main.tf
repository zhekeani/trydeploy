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


# Service account role
module "project_iam_bindings" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 7.7"

  projects = [data.google_project.current.project_id]

  bindings = {
    "roles/artifactregistry.reader" = [
      "serviceAccount:${var.service_account_email}",
    ]
  }
}