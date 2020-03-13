#######################################
############## GCE ####################
#######################################
output "vault_static_ip" {
  description = "Created compute address."
  value       = google_compute_address.vault_static_ip.address
}

#######################################
############## GCS ####################
#######################################
output "gcs_bucket_name" {
  value = google_storage_bucket.vault-ha-storage.name
}

#######################################
############## IAM ####################
#######################################
output "vault_service_account_key" {
  value = google_service_account_key.vault_service_account_key.private_key
}

#######################################
############## Google Cloud ###########
#######################################
output "project_name" {
  value = google_service_account.vault_service_account.project
}


#######################################
############## KMS ####################
#######################################
output "kms_region" {
  value = google_kms_key_ring.vault-keyring.location
}

output "kms_keyring" {
  value = google_kms_key_ring.vault-keyring.name
}

output "kms_crypto_key" {
  value = google_kms_crypto_key.vault-crypto-key.name
}

output "kms_crypto_key_id" {
  value = google_kms_crypto_key.vault-crypto-key.self_link
}