output "secret_accessor_private_key" {
  value       = google_service_account_key.secret_accessor.private_key
  sensitive   = true
  description = "Private key for service account with secret accessor role."
}

output "secret_accessor_svc" {
  value       = google_service_account.secret_accessor
  sensitive   = false
  description = "Service account to be assigned with secret accessor role."
}
