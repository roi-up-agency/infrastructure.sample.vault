#!/usr/bin/env bash

[[ ! -d tls ]] && echo "tls directory already exists, I assume certificates are created. Aborting." && exit 1;

command -v kubectl >/dev/null 2>&1 || { echo >&2 "I require kubectl cli but it's not installed.  Aborting."; exit 1; }

STATIC_IP=$(cd ../terraform ; terraform output -json | jq '.vault_static_ip.value')

GOOGLE_CLOUD_PROJECT=$(cd ../terraform ; terraform output -json | jq '.project_name.value')

GCS_BUCKET=$(cd ../terraform ; terraform output -json | jq '.gcs_bucket_name.value')

KMS_REGION=$(cd ../terraform ; terraform output -json | jq '.kms_region.value')

KMS_KEY_RING=$(cd ../terraform ; terraform output -json | jq '.kms_keyring.value')

KMS_CRYPTO_KEY=$(cd ../terraform ; terraform output -json | jq '.kms_crypto_key.value')

KMS_CRYPTO_KEY_ID=$(cd ../terraform ; terraform output -json | jq '.kms_crypto_key_id.value')

kubectl create configmap vault \
    --from-literal "load_balancer_address=${STATIC_IP}" \
    --from-literal "gcs_bucket_name=${GCS_BUCKET}" \
    --from-literal "kms_project=${GOOGLE_CLOUD_PROJECT}" \
    --from-literal "kms_region=${KMS_REGION}" \
    --from-literal "kms_key_ring=${KMS_KEY_RING}" \
    --from-literal "kms_crypto_key=${KMS_CRYPTO_KEY}" \
    --from-literal="kms_key_id=${KMS_CRYPTO_KEY_ID}"


kubectl create secret generic vault-tls \
    --from-file "$(pwd)/tls/ca.crt" \
    --from-file "vault.crt=$(pwd)/tls/vault-combined.crt" \
    --from-file "vault.key=$(pwd)/tls/vault.key";


kubectl apply -f ../statefulset.yml


kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: vault
  labels:
    app: vault
spec:
  type: LoadBalancer
  loadBalancerIP: ${STATIC_IP}
  externalTrafficPolicy: Local
  selector:
    app: vault
  ports:
  - name: vault-port
    port: 443
    targetPort: 8200
    protocol: TCP
EOF