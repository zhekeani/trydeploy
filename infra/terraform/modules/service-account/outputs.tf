output "secret_accessor_private_key" {
  value       = google_service_account_key.trydeploy["secret_accessor"].private_key
  sensitive   = true
  description = "Private key for service account with secret accessor role."
}

output "secret_accessor_svc" {
  value       = google_service_account.trydeploy["secret_accessor"]
  sensitive   = false
  description = "Service account to be assigned with secret accessor role."
}

output "sa_private_keys" {
  value = {
    for service_account_name, service_account in google_service_account_key.trydeploy :
    service_account_name => service_account.private_key
  }
  sensitive   = true
  description = "All service accounts key."
  depends_on  = [google_service_account_key.trydeploy]
}


output "sa_properties" {
  value = {
    for service_account_name, service_account in google_service_account.trydeploy :
    service_account_name => service_account
  }
  sensitive   = false
  description = "All service accounts properties."
  depends_on  = [google_service_account.trydeploy]
}
