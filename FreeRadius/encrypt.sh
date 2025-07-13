#!/bin/bash

# Generate and save a key for encryption, this should be a variable in CI/CD (run this once)
# openssl rand -base64 32 > encryption.key

#Color
RED='\033[1;31m'
NOCOLOR='\033[0m'

# Check if ENCRYPTION_KEY variable is set
if [ -z "$ENCRYPTION_KEY" ]; then
    echo -e ${RED}""ERROR:${NOCOLOR}" ENCRYPTION_KEY variable is not set" >&2
    exit 1
fi

# Prechecks
echo "Checking Base64 Encoded variable"
# Remove spaces and check if it's a proper 44-character base64 string
clean_key=$(echo -n "$ENCRYPTION_KEY" | tr -d '[:space:]')

if [[ ${#clean_key} -ne 44 ]]; then
  echo -e ${RED}""ERROR:${NOCOLOR}" Invalid key length. Expected 44 characters."
  exit 1
fi

# Base64 validation using regex (must be base64 with 0, 1, or 2 '=' padding)
if ! [[ "$clean_key" =~ ^[A-Za-z0-9+/]*={0,2}$ ]]; then
  echo -e ${RED}""ERROR:${NOCOLOR}" Invalid Base64 format."
  exit 1
fi

# Try decoding to validate Base64
if ! echo -n "$clean_key" | base64 -d >/dev/null 2>&1; then
  echo -e ${RED}""ERROR:${NOCOLOR}" Invalid Base64. Decoding failed."
  exit 1
fi

echo "✅ Base64 is valid."
ENCRYPTION_KEY="$clean_key"

echo "Comparing SHA256 Hashes to see if our encryption key is what it should be"
# SHA256 hash of the key to verify its the correct one
stored_sha256=yourhashofthekeyshouldbehere

# Generate SHA-256 Hash of the key
current_sha256=$(echo -n "$ENCRYPTION_KEY" | sha256sum | awk '{print $1}')

# Output Hashed vaules
echo Generated Hash: $current_sha256
echo Stored Hash:    $stored_sha256

if [[ "$current_sha256" == "$stored_sha256" ]]; then
    echo "✅ Key matched the stored SHA-256 hash. Integrity verified."
else
    echo -e ${RED}""ERROR:${NOCOLOR}" Key does not match the stored SHA-256 hash...Exiting.."
    exit 1
fi

# List of specific files to encrypt (Modify as needed)
FILES_TO_ENCRYPT=(
    "clients.conf"
    "mods-available/ldap"
)

# Loop through the specified files
for file in "${FILES_TO_ENCRYPT[@]}"; do
    if [ ! -f "$file" ]; then
        echo "⚠️ Skipping $file (File not found)"
        continue
    fi

    echo "🔐 Encrypting $file..."

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Match both 'secret' and 'password' fields.
        if [[ "$line" =~ ^([[:space:]]*(secret|password)[[:space:]]*=[[:space:]]*)ENC:(.*) ]]; then
           # If the secret is already encrypted, keep it as is.
           printf "%s\n" "$line"
        elif [[ "$line" =~ ^([[:space:]]*(secret|password)[[:space:]]*=[[:space:]]*)(.*) ]]; then
            PREFIX="${BASH_REMATCH[1]}" # Preserve spacing
            ENCODED_SECRET="${BASH_REMATCH[3]}" # Extract secret/password vaule
            # Encrypt and encode in base64
            ENCRYPTED_SECRET=$(printf "%s" "$ENCODED_SECRET" | openssl enc -aes-256-cbc -salt -pbkdf2 -md sha256 -pass pass:"$ENCRYPTION_KEY" | openssl base64 | tr -d '\n')
            printf "%s\n" "${PREFIX}ENC:$ENCRYPTED_SECRET"
        else
            printf "%s\n" "$line"
        fi
    done < "$file" > "${file}.dec"

    # Move the decrypted file back to its original location
    mv "${file}.dec" "$file"
    echo "✅ Encryption complete for $file"
done

echo "✅ All files have been encrypted."
