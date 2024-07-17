#!/bin/bash

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL could not be found. Please install OpenSSL to continue."
    exit 1
fi

# Generate a self-signed certificate and private key
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=localhost"

echo "TLS certificates generated successfully."
