#!/bin/bash

# Generate and save a key for encryption (run this once)
# openssl rand -base64 32 > encryption.key

# Load the encryption key
ENCRYPTION_KEY=$(cat encryption.key)

# Read the file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^([[:space:]]*secret[[:space:]]*=[[:space:]]*)(.*) ]]; then
        PREFIX="${BASH_REMATCH[1]}"  # Preserve spacing before and around =
        SECRET="${BASH_REMATCH[2]}"  # Extract the actual secret

        # Encrypt and encode in base64
        ENCRYPTED_SECRET=$(echo -n "$SECRET" | openssl enc -aes-256-cbc -salt -pbkdf2 -md sha256 -pass pass:"$ENCRYPTION_KEY" | base64 -w 0)

        echo "${PREFIX}ENC:$ENCRYPTED_SECRET"
    else
        echo "$line"
    fi
done < clients.conf > clients.conf.enc

# Replace the original file
mv clients.conf.enc clients.conf
echo "Encryption complete."
