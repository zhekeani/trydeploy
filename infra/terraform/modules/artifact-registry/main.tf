# Get the current project data
data "google_project" "current" {}

# Enable the APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = data.google_project.current.project_id
  enable_apis                 = true
  disable_services_on_destroy = false

  activate_apis = [
    "artifactregistry.googleapis.com",
  ]
}

locals {
  nestjs_repositories_name = ["predictions"]
}


# trytumor Kubernetes micro-service repositories
resource "google_artifact_registry_repository" "nestjs_repo" {
  for_each = toset(local.nestjs_repositories_name)

  location      = var.location
  repository_id = "${var.environment.prefix}-${data.google_project.current.name}-${each.value}"
  description   = "${data.google_project.current.name}-${each.value} docker repository"
  format        = "DOCKER"

  labels = {
    environment = var.environment.type
    app         = "backend"
    security    = "internal"
    region      = var.location
  }
}