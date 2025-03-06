#!/bin/bash

# Load the encryption key
ENCRYPTION_KEY=$(cat encryption.key)

# Read the file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^([[:space:]]*secret[[:space:]]*=[[:space:]]*)ENC:(.*) ]]; then
        PREFIX="${BASH_REMATCH[1]}"  # Preserve spacing before and around =
        ENCODED_SECRET="${BASH_REMATCH[2]}"  # Extract encrypted base64 part

        # Decode Base64 and decrypt
        echo "$ENCODED_SECRET" | base64 -d > temp_encrypted.bin
        DECRYPTED_SECRET=$(openssl enc -d -aes-256-cbc -salt -pbkdf2 -md sha256 -pass pass:"$ENCRYPTION_KEY" -in temp_encrypted.bin 2>/dev/null)

        if [ $? -ne 0 ] || [ -z "$DECRYPTED_SECRET" ]; then
            echo "Error: Failed to decrypt" >&2
            echo "${PREFIX}ENC:$ENCODED_SECRET"  # Preserve original if decryption fails
        else
            echo "${PREFIX}${DECRYPTED_SECRET}"
        fi

        rm -f temp_encrypted.bin
    else
        echo "$line"
    fi
done < clients.conf > clients.conf.dec

# Replace the original file
mv clients.conf.dec clients.conf
echo "Decryption complete."
