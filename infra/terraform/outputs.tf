
output "sa_private_key_secrets" {
  value = {
    for service_account_name, secret_version in module.sa_private_key_secrets :
    service_account_name => secret_version.secret_data
  }
  sensitive   = true
  description = "All service accounts private key."
}

output "sa_private_key_secrets_path" {
  value       = {
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
  value       = {
    for service_account_name, service_account in module.service_account.sa_properties :
    service_account_name => service_account.email
  }
  sensitive   = false
  description = "description"
  depends_on  = [module.service_account]
}
