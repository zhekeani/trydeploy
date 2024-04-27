data "google_project" "current" {}


# Enable the used APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = data.google_project.current.project_id
  enable_apis                 = true
  disable_services_on_destroy = false

  activate_apis = [
    "storage.googleapis.com"
  ]
}

# Create storage bucket
resource "google_storage_bucket" "public_media_bucket" {
  name                        = var.bucket_name
  location                    = var.location
  force_destroy               = true
  project                     = data.google_project.current.project_id
  uniform_bucket_level_access = false

  labels = {
    environment = var.environment.type
    app         = "backend"
    security    = "public"
    region      = var.location
  }

  depends_on = [module.project-services]
}

# Assign object admin role to service account
module "storage_bucket-iam-bindings" {
  source          = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  mode            = "additive"
  storage_buckets = ["${google_storage_bucket.public_media_bucket.name}"]

  bindings = {
    "roles/storage.objectAdmin" = [
      "serviceAccount:${var.object_admin_sa_email}"
    ]
  }
}