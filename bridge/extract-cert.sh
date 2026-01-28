#!/bin/bash

set -ex

acme_file=/etc/traefik/acme/acme.json
cert_dir=/root

mkdir -p $cert_dir

jq -r ".letsencrypt.Certificates[] | select(.domain.main==\"$BRIDGE_HOSTNAME\") | .certificate" $acme_file | base64 -d > $cert_dir/cert.pem
jq -r ".letsencrypt.Certificates[] | select(.domain.main==\"$BRIDGE_HOSTNAME\") | .key" $acme_file | base64 -d > $cert_dir/key.pem
