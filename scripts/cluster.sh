#!/usr/bin/env bash
gcloud container clusters create vault \
--cluster-version 1.14 \
--enable-autorepair \
--enable-autoupgrade \
--enable-ip-alias \
--machine-type n1-highcpu-2 \
--node-version 1.14 \
--num-nodes 2 \
--region europe-west4-a \
--scopes cloud-platform \
--service-account "${SERVICE_ACCOUNT}"

kubectl create configmap vault \
    --from-literal "load_balancer_address=${LB_IP}" \
    --from-literal "gcs_bucket_name=${GOOGLE_CLOUD_PROJECT}-vault-storage" \
    --from-literal "kms_project=${GOOGLE_CLOUD_PROJECT}" \
    --from-literal "kms_region=global" \
    --from-literal "kms_key_ring=daas" \
    --from-literal "kms_crypto_key=vault-auto-unseal" \
    --from-literal="kms_key_id=projects/${GOOGLE_CLOUD_PROJECT}/locations/global/keyRings/daas/cryptoKeys/vault-auto-unseal"

kubectl create secret generic vault-tls \
--from-file "$(pwd)/cert/scripts/ca.crt" \
--from-file "vault.crt=$(pwd)/cert/scripts/vault-combined.crt" \
--from-file "vault.key=$(pwd)/cert/scripts/vault.key"

export VAULT_TOKEN="$(gsutil cat "gs://${GOOGLE_CLOUD_PROJECT}-vault-storage/root-token.enc" | \
  base64 --decode | \
  gcloud kms decrypt \
    --location global \
    --keyring daas \
    --key vault-auto-unseal \
    --ciphertext-file - \
    --plaintext-file -)"