
output "current_project_id" {
  value       = data.google_project.current.project_id
  sensitive   = true
  description = "Current active Google Cloud project ID."
  depends_on  = [data.google_project.current]
}

output "gke_cluster_name" {
  value       = module.kubernetes_engine.gke_cluster_name
  sensitive   = false
  description = "GKE cluster name."
  depends_on  = [module.kubernetes_engine]
}


output "gke_cluster_region" {
  value       = module.kubernetes_engine.gke_cluster_region
  sensitive   = false
  description = "GKE cluster region."
  depends_on  = [module.kubernetes_engine]
}



output "sa_private_key_secrets" {
  value = {
    for service_account_name, secret_version in module.sa_private_key_secrets :
    service_account_name => secret_version.secret_data
  }
  sensitive   = true
  description = "All service accounts private key."
}

output "sa_private_key_secrets_path" {
  value = {
    for service_account, secret_version in module.sa_private_key_secrets :
    service_account => secret_version.secret_path
  }
  sensitive   = false
  description = "Path to service account keys that stored in Secret Manager."
  depends_on  = [module.sa_private_key_secrets]
}


output "dummy_secret_version_path" {
  value       = module.dummy_secret_version.secret_path
  sensitive   = false
  description = "Dummy secret version path"
  depends_on  = [module.dummy_secret_version]
}

output "service_accounts_email" {
  value = {
    for service_account_name, service_account in module.service_account.sa_properties :
    service_account_name => service_account.email
  }
  sensitive   = false
  description = "description"
  depends_on  = [module.service_account]
}


output "ar_nestjs_repositories_url" {
  value       = module.artifact_registry.nestjs_repositories_url
  sensitive   = false
  description = "NestJS micro-services Artifact Registry repositories URL."
  depends_on  = [module.artifact_registry]
}
