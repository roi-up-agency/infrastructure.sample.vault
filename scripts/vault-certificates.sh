#!/usr/bin/env bash

[[ -d tls ]] && echo "tls directory already exists, I assume certificates are created. Aborting." && exit 1;

TLS_DIR="tls"

command mkdir -p ${TLS_DIR}

command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq cli but it's not installed.  Aborting."; exit 1; }
command -v gcloud >/dev/null 2>&1 || { echo >&2 "I require gcloud  cli but it's not installed.  Aborting."; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo >&2 "I require terraform cli but it's not installed.  Aborting."; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo >&2 "I require openssl cli but it's not installed.  Aborting."; exit 1; }

STATIC_IP=$(cd ../terraform ; terraform output -json | jq '.vault_static_ip.value')

echo ${STATIC_IP}


cat > "${TLS_DIR}/openssl.cnf" << EOF
[req]
default_bits = 2048
encrypt_key  = no
default_md   = sha256
prompt       = no
utf8         = yes

distinguished_name = req_distinguished_name
req_extensions     = v3_req

[req_distinguished_name]
C  = US
ST = California
L  = The Cloud
O  = Demo
CN = vault

[v3_req]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names

[alt_names]
IP.1  = ${STATIC_IP}
DNS.1 = vault.default.svc.cluster.local
EOF


openssl rand 4096 >> ${HOME}/.rnd;

# Generate Vault's certificate and certificate signing request (CSR):
openssl genrsa -out "${TLS_DIR}/vault.key" 2048

openssl req \
    -new -key "${TLS_DIR}/vault.key" \
    -out "${TLS_DIR}/vault.csr" \
    -config "${TLS_DIR}/openssl.cnf";

# Create a Certificate Authority (CA):
openssl req \
    -new \
    -newkey rsa:2048 \
    -days 120 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=California/L=The Cloud/O=Vault CA" \
    -keyout "${TLS_DIR}/ca.key" \
    -out "${TLS_DIR}/ca.crt";

# Sign the CSR with the CA:
openssl x509 \
    -req \
    -days 120 \
    -in "${TLS_DIR}/vault.csr" \
    -CA "${TLS_DIR}/ca.crt" \
    -CAkey "${TLS_DIR}/ca.key" \
    -CAcreateserial \
    -extensions v3_req \
    -extfile "${TLS_DIR}/openssl.cnf" \
    -out "${TLS_DIR}/vault.crt";


#  Finally, combine the CA and Vault certificate (this is the format Vault expects):
cat "${TLS_DIR}/vault.crt" "${TLS_DIR}/ca.crt" > "${TLS_DIR}/vault-combined.crt"


