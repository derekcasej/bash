#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <hostname> <email>"
    exit 1
fi

HOSTNAME=$1
EMAIL=$2

# Perform a dry run with Certbot
certbot certonly \
    --dry-run \
    --non-interactive \
    --standalone \
    --agree-tos \
    --email "$EMAIL" \
    -d "$HOSTNAME"

if [ $? -eq 0 ]; then
    echo "Dry run successful. Generating a real certificate."
    
    # Run the actual Certbot command to generate a certificate
    certbot certonly \
        --non-interactive \
        --standalone \
        --agree-tos \
        --email "$EMAIL" \
        -d "$HOSTNAME"
    
    if [ $? -eq 0 ]; then
        echo "Certificate generation successful."
    else
        echo "Certificate generation failed. Check the above output for details."
    fi
else
    echo "Dry run failed. Check the above output for details."
fi
