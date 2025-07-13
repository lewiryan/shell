#!/bin/bash

#Color
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NOCOLOR='\033[0m'

# List of specific files to check (Modify as needed)
FILES_TO_CHECK=(
    "clients.conf"
    "mods-available/ldap"
)
UNENCRYPTED_FOUND=0 # Flag to track unencrypted secrets

# Loop through the specified files
for file in "${FILES_TO_CHECK[@]}"; do
    if [ ! -f "$file" ]; then
        echo "⚠️ Skipping $file (File not found)"
        continue
    fi
    
    echo "🔎 Checking $file..."
    line_number=0 # Line Number counter
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_number=$((line_number +1)) # +1 line the number

        # Trim leading and trailing whitespace from the line
        trimmed_line=$(echo "$line" | awk '{$1=$1};1')
    
        # Extract the key and value, trimming any extra spaces around them
        key=$(echo "$trimmed_line" | cut -d '=' -f 1 | awk '{$1=$1};1')
        value=$(echo "$trimmed_line" | cut -d '=' -f 2 | awk '{$1=$1};1')
    
        # Check if the key is "secret" or "password" and the value does NOT start with "ENC:"
        if [[ "$key" == "secret" || "$key" == "password" ]] && [[ "$value" != ENC:* ]]; then
            echo -e ${YELLOW}"WARNING:${NOCOLOR} Unencrypted secret found in $file" 
            echo -e ${YELLOW}"WARNING:${NOCOLOR} Line Number: $line_number"
            echo "⚠️ $line" >&2
            UNENCRYPTED_FOUND=1
        fi
done < "$file"



done

# Final check: If no unencrypted secrets were found, exit successfully
if [ "$UNENCRYPTED_FOUND" -eq 0 ]; then
    echo "✅ All secrets are encrypted."
    exit 0
else
    echo -e ${RED}""ERROR:${NOCOLOR}" Some secret(s) are not encrypted!"
    echo -e ${BLUE}""INFO:${NOCOLOR}" All secrets and passwords must be encrypted before this file can be merged into main branch."
    exit 1
fi

