#!/usr/bin/env bash

GOOGLE_CLOUD_PROJECT="daas-security"

CLUSTER_NAME="web-sec"

CLUSTER_REGION="europe-west4-a"

SERVICE_ACCOUNT_NAME="vault-auth" ## check the name is used in the file: token-reviewer-rbac.yml

EXTERNAL_IP_NAME="vault"

EXTERNAL_IP_REGION="europe-west4"

VAULT_AUTH_PATH="ory"

kubectl create serviceaccount ${SERVICE_ACCOUNT_NAME}

kubectl apply -f token-reviewer-rbac.yml

LB_IP="$(gcloud compute addresses describe ${EXTERNAL_IP_NAME} --region ${EXTERNAL_IP_REGION} --format 'value(address)')"

## cluster fully qualified name.
CLUSTER_FQ_NAME="gke_${GOOGLE_CLOUD_PROJECT}_${CLUSTER_REGION}_${CLUSTER_NAME}"

SECRET_NAME="$(kubectl get serviceaccount vault-auth -o go-template='{{ (index .secrets 0).name }}')"

TR_ACCOUNT_TOKEN="$(kubectl get secret ${SECRET_NAME} -o go-template='{{ .data.token }}' | base64 --decode)"

K8S_HOST="$(kubectl config view --raw -o go-template="{{ range .clusters }}{{ if eq .name \"${CLUSTER_FQ_NAME}\" }}{{ index .cluster \"server\" }}{{ end }}{{ end }}")"

K8S_CACERT="$(kubectl config view --raw -o go-template="{{ range .clusters }}{{ if eq .name \"${CLUSTER_FQ_NAME}\" }}{{ index .cluster \"certificate-authority-data\" }}{{ end }}{{ end }}" | base64 --decode)"

vault auth enable -path=${VAULT_AUTH_PATH} kubernetes

vault write auth/${VAULT_AUTH_PATH}/config kubernetes_host="${K8S_HOST}" kubernetes_ca_cert="${K8S_CACERT}" token_reviewer_jwt="${TR_ACCOUNT_TOKEN}"

kubectl create configmap vault --from-literal "vault_addr=https://${LB_IP}"

kubectl create secret generic vault-tls --from-file "$(pwd)/cert/scripts/ca.crt"
#kubectl create secret generic vault-scripts --from-file "ca.crt"