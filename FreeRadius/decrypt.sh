#!/bin/bash

# Load the encryption key
ENCRYPTION_KEY=$(cat encryption.key)

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

# List of specific files to decrypt (Modify as needed)
FILES_TO_DECRYPT=(
    "clients.conf"
    "mods-available/ldap"
)

# Loop through the specified files
for file in "${FILES_TO_DECRYPT[@]}"; do
    if [ ! -f "$file" ]; then
        echo "⚠️ Skipping $file (File not found)"
        continue
    fi

    echo "🔓 Decrypting $file..."

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Match both 'secret' and 'password' fields with ENC:
        if [[ "$line" =~ ^([[:space:]]*(secret|password)[[:space:]]*=[[:space:]]*)ENC:(.*) ]]; then
            PREFIX="${BASH_REMATCH[1]}" # Preserve spacing
            ENCODED_SECRET="${BASH_REMATCH[3]}" # Extract encrypted base64 part

            # Add Base64 Padding to avoid the OpenSSL error invaild input, if needed.
            remainder=$(( ${#ENCODED_SECRET} % 4 ))
            if [[ $remainder -eq 2 ]]; then
                 ENCODED_SECRET="${ENCODED_SECRET}=="
            elif [[ $remainder -eq 3 ]]; then
                ENCODED_SECRET="${ENCODED_SECRET}="
            fi

            # Decode base64 and decrypt
            DECRYPTED_SECRET=$(printf "%s\n" "$ENCODED_SECRET" | openssl enc -d -base64 | openssl enc -d -aes-256-cbc -salt -pbkdf2 -md sha256 -pass pass:"$ENCRYPTION_KEY")

            if [ $? -ne 0 ] || [ -z "$DECRYPTED_SECRET" ]; then
                echo -e ${RED}""ERROR:${NOCOLOR}" Error: Failed to decrypt in $file" >&2
                echo "${PREFIX}ENC:$ENCODED_SECRET"
                exit 1
            else
                echo "${PREFIX}${DECRYPTED_SECRET}"
            fi

        else
            echo "$line"
        fi
    done < "$file" > "${file}.dec"

    # Move the decrypted file back to its original location
    mv "${file}.dec" "$file"
    echo "✅ Decryption complete for $file"
done

echo "🔓 Selected files have been decrypted."


# Replace the original file
mv clients.conf.dec clients.conf
echo "Decryption complete."
