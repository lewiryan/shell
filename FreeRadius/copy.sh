#!/bin/bash

# Source directory is the current working directory
SOURCE_DIR=$(pwd)
DEST_DIR="/etc/raddb"

# Permissions
DIR_PERMISSIONS=750
FILE_PERMISSIONS=640

# Ownership
OWNER="root"
GROUP="radiusd"

# Move all files and directories from source to destination
sudo cp -R "$SOURCE_DIR"/* "$DEST_DIR"/

# Set permissions for directories
sudo find "$DEST_DIR" -type d -exec chmod "$DIR_PERMISSIONS" {} \;

# Set permissions for files
sudo find "$DEST_DIR" -type f -exec chmod "$FILE_PERMISSIONS" {} \;

# Change ownership recursively
sudo chown -R "$OWNER":"$GROUP" "$DEST_DIR"

echo "✅ Files and directories moved, permissions, and ownership set."
