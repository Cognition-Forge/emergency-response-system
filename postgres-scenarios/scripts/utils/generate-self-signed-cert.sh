#!/bin/sh
# Generate a local self-signed certificate for development TLS.
set -euo pipefail

CERT_DIR=${1:-$(dirname "$0")/../../certs}
mkdir -p "$CERT_DIR"

openssl req \
  -x509 \
  -nodes \
  -newkey rsa:2048 \
  -keyout "$CERT_DIR/server.key" \
  -out "$CERT_DIR/server.crt" \
  -days 3650 \
  -subj "/CN=localhost"

chmod 600 "$CERT_DIR/server.key"
chmod 644 "$CERT_DIR/server.crt"

echo "Self-signed certificate written to $CERT_DIR"
