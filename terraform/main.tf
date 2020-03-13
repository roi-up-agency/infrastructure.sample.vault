provider "google" {
  version = "3.5.0"

  credentials = file(var.credentials_file)
  project = var.project
  region  = var.region
  zone    = var.zone
}

//data "google_service_account" "vault_service_account" {
//  project = var.project
//  account_id = var.vault_service_account
//}
//
resource "google_service_account" "vault_service_account"  {
  account_id   = var.vault_service_account_id
  display_name = "Vault service account"
}


resource "google_service_account_key" "vault_service_account_key" {
  service_account_id = google_service_account.vault_service_account.account_id
}

data "google_iam_policy" "vault_storage" {
  binding {
    role = "roles/storage.legacyBucketReader"
    members = [
      google_service_account_key.vault_service_account_key.id
    ]
  }
  binding {
    role = "roles/storage.objectAdmin"
    members = [
      google_service_account.vault_service_account.email
    ]
  }
}

resource "google_storage_bucket_iam_policy" "vault-storage" {
  bucket = google_storage_bucket.vault-ha-storage.name
  policy_data = data.google_iam_policy.vault_storage.policy_data
}

resource "google_kms_key_ring_iam_binding" "vault-init" {
  key_ring_id = var.keyring_name
  members = [
    google_service_account.vault_service_account.email
  ]
  role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

resource "google_storage_bucket" "vault-ha-storage" {
  name          = var.storage_name
  location      = "EU"
  force_destroy = true
  bucket_policy_only = true
}

resource "google_kms_key_ring" "vault-keyring" {
  name     = var.keyring_name
  location = var.keyring_location
}

resource "google_kms_crypto_key" "vault-crypto-key" {
  name            = var.cryptokey_name
  key_ring        = google_kms_key_ring.vault-keyring.self_link
  purpose = "ENCRYPT_DECRYPT"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_address" "vault_static_ip" {
  name = "vault-static-ip"
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

//  network = "projects/daas-vpc-master/global/networks/daas-suite-test-network"
//  subnetwork = "projects/daas-vpc-master/regions/europe-west1/subnetworks/main-subnet-nodes-test-daas-security-eu-west-1"
//  ip_allocation_policy {
//    # usar directamente el nombre de subredes ya creadas
//    cluster_secondary_range_name = "secundary-subnet-pods-test-daas-security-eu-west-1"
//    services_secondary_range_name = "secundary-subnet-services-test-daas-security-eu-west-1"
//    //    cluster_ipv4_cidr_block = "10.4.0.0/14"
//    //    services_ipv4_cidr_block = "10.0.32.0/20"
//  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.cluster_name
  # it will only create 2 nodes in the zone: europe-west4-a
  # if I use region, it will create 2 nodes for each zone available in the region
  location = var.zone

  cluster    = google_container_cluster.primary.name
  node_count = var.number_nodes

  node_config {
    service_account = google_service_account.vault_service_account.email
    preemptible  = true
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
