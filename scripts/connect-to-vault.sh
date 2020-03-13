#!/usr/bin/env bash

export LB_IP="$(gcloud compute addresses describe vault --region europe-west4 --format 'value(address)')" \

export VAULT_ADDR="https://${LB_IP}:443" \

export VAULT_CACERT="$(pwd)/cert/scripts/ca.crt" \

export GOOGLE_CLOUD_PROJECT="daas-security" \

export VAULT_TOKEN="$(gsutil cat "gs://${GOOGLE_CLOUD_PROJECT}-vault-storage/root-token.enc" | \
  base64 --decode | \
  gcloud kms decrypt \
    --location global \
    --keyring daas \
    --key vault-auto-unseal \
    --ciphertext-file - \
    --plaintext-file -)"
