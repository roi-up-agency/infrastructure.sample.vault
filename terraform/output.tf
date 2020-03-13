output "vault_static_ip" {
  description = "Created compute address."
  value       = google_compute_address.vault_static_ip.address
}

output "vault_service_account_key" {
  value = google_service_account_key.vault_service_account_key.private_key
}