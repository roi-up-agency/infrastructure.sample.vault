variable "credentials_file" {
  default = "key.json"
}

variable "project" {
  type = string
  default = "daas-internal-security"
}

#######################################
############## IAM ####################
#######################################
variable "vault_service_account_id" {
  default = "vault-server"
}

#######################################
############## GCS ####################
#######################################
variable "storage_name" {
  default = "vault-ha-storage-9000"
}

#######################################
############## KMS ####################
#######################################
variable "keyring_name" {
  default = "vault-keyring"
}

variable "keyring_location" {
  default = "vault-keyring"
}

variable "cryptokey_name" {
  default = "vault-cryptonite"
}

#######################################
############## GKE ####################
#######################################
variable "region" {
  default = "europe-west4"
}

variable "zone" {
  default = "europe-west4-a"
}

variable "machine_type" {
  default = "n1-highcpu-1"
}

variable "number_nodes" {
  type = number
  default = 2
}

variable "cluster_name" {
  default = "vault"
}