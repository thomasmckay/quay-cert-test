#!/bin/bash

HOSTNAME=devel.example.com

openssl genrsa -out tmp/rootCA.key 2048
openssl req -x509 -new -nodes -key tmp/rootCA.key -sha256 -days 1024 -out tmp/rootCA.pem -subj '/CN=$HOSTNAME'

cat <<EOF > tmp/openssl.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $HOSTNAME
IP.1 = 192.168.123.230
EOF

openssl genrsa -out tmp/quay.key 2048
openssl req -new -key tmp/quay.key -out tmp/quay.csr -subj "/CN=$HOSTNAME" -config tmp/openssl.conf
openssl x509 -req -in tmp/quay.csr -CA tmp/rootCA.pem -CAkey tmp/rootCA.key -CAcreateserial -out tmp/quay.crt -days 356 -extensions v3_req -extfile tmp/openssl.conf

openssl genrsa -out tmp/clair.key 2048
openssl req -new -key tmp/clair.key -out tmp/clair.csr -subj "/CN=$HOSTNAME" -config tmp/openssl.conf
openssl x509 -req -in tmp/clair.csr -CA tmp/rootCA.pem -CAkey tmp/rootCA.key -CAcreateserial -out tmp/clair.crt -days 356 -extensions v3_req -extfile tmp/openssl.conf

mkdir -p tmp
cp tmp/quay.crt quay-config/ssl.crt
cp tmp/quay.key quay-config/ssl.key
cp tmp/rootCA.pem quay-config/ca.crt

cp tmp/clair.crt clair-config/ssl.crt
cp tmp/clair.key clair-config/ssl.key
cp tmp/rootCA.pem clair-config/ca.crt
