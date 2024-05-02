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

variable "location" {
  type        = string
  description = "Project's location."
}


variable "service_account_email" {
  type        = string
  description = "Service account to be assigned secret accessor role."
}

variable "secrets_name" {
  type        = list(string)
  description = "Secret name to be granted access."
}

variable "bucket_name" {
  type        = string
  description = "Storage bucket name that will be accessed by Kubernetes service account."
}

variable "repositories_name" {
  type        = list(string)
  description = "The name of the repositories in Artifact Registry where the Kubernetes Engine container image is stored."
}



# Service account role
module "project_iam_bindings" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 7.7"

  projects = [data.google_project.current.project_id]

  bindings = {
    "roles/container.clusterAdmin" = [
      "serviceAccount:${var.service_account_email}",
    ]
    "roles/container.developer" = [
      "serviceAccount:${var.service_account_email}",
    ]
    "roles/compute.instanceAdmin" = [
      "serviceAccount:${var.service_account_email}",
    ]
    "roles/monitoring.metricWriter" = [
      "serviceAccount:${var.service_account_email}",
    ]
    "roles/logging.logWriter" = [
      "serviceAccount:${var.service_account_email}",
    ]
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${var.service_account_email}",
    ]
    "roles/iam.roleViewer" = [
      "serviceAccount:${var.service_account_email}",
    ]
    "roles/artifactregistry.reader" = [
      "serviceAccount:${var.service_account_email}",
    ]
  }
}

# Storage bucket role
module "storage_bucket-iam-bindings" {
  source          = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  mode            = "additive"
  storage_buckets = ["${var.bucket_name}"]

  bindings = {
    "roles/storage.objectAdmin" = [
      "serviceAccount:${var.service_account_email}"
    ]
  }
}

# Artifact Registry repositories role
resource "google_artifact_registry_repository_iam_binding" "binding" {
  for_each = toset(var.repositories_name)

  project    = data.google_project.current.project_id
  location   = var.location
  repository = each.value
  role       = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

# Secret accessor role
resource "google_secret_manager_secret_iam_member" "member" {
  for_each = toset(var.secrets_name)

  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}