#!/bin/bash

# Define the destination and remote server details
REMOTE_USER="wisnu"
REMOTE_HOST="192.168.225.2"
REMOTE_PATH="/mnt/trusmicorp/rspproject/"

# Define the source path
SOURCE_PATH="/var/www/html/rspproject/"

# List of files and directories to sync
FILES=(
    "6114cb128525c.png"
    "6114de8796aaa.png"
    "63c2542914286.png"
    "63e4a84aeb1b2.png"
    "api-taptalk.txt"
    "application"
    "approve_spk.php"
    #"assets"
    "composer.json"
    "composer.lock"
    "contributing.md"
    "dummy.json"
    "event.json"
    "fcmToken.txt"
    "F"
    "google-services.json"
    "I"
    "index.php"
    "konsumen.txt"
    "license.txt"
    "manifest.json"
    "readme.rst"
    "robots.txt"
    "rsp_project_live.sql"
    "service-worker.js"
    "service-workerold.js"
    "sitemap.xml"
    "sweetalert"
    "system"
    "tbns-small.png"
    "trusmiland-round.png"
    "UPLOAD_DIR"
    "vendor"
    "vendor4"
)

# Loop through each file/directory and sync it
for ITEM in "${FILES[@]}"; do
    echo "Syncing $ITEM to $REMOTE_HOST:$REMOTE_PATH"
    rsync -avz --progress "$SOURCE_PATH$ITEM" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
done

echo "All files have been synchronized."
