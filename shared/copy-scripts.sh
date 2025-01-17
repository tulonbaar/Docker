#!/bin/bash

# Setup logging colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Load configuration
DOCKER_DIR=$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")

APP_NAME="$1"
BASE_PATH="$DOCKER_DIR/apps/$NAME"

# echo DOCKER_DIR: "$DOCKER_DIR"
# echo BASE_PATH: "$BASE_PATH"

if [ -z "$APP_NAME" ]; then
    echo "No APP_NAME provided. Will copy scripts for all apps"
    APP_NAMES=($(ls "$DOCKER_DIR/apps"))
    echo APP_NAMES: "${APP_NAMES[*]}"
    echo "Found ${#APP_NAMES[@]} applications"
else
    APP_NAMES=("$APP_NAME")
    echo APP_NAMES: "${APP_NAMES[*]}"
    echo "Found 1 application"
fi

# Construct the absolute path to the config file
CONFIG_FILE="$DOCKER_DIR/shared/shared_scripts/config.yaml"
BIND_PATH=$(yq -r '.BIND_PATH' "$CONFIG_FILE")
BASE_DEST_PATH="$BIND_PATH/shared-scripts_data"

# echo BIND_PATH: "$BIND_PATH"
# echo BASE_DEST_PATH: "$BASE_DEST_PATH"

# Function to copy scripts
copy_scripts() {
    # Get all directories from apps folder
    for APP in "$DOCKER_DIR"/apps/*/; do
        APP=${APP%*/}      # Remove trailing slash
        APP=${APP##*/}     # Get only the directory name
        echo -e "${YELLOW}Processing application: $APP${NC}"
        if [ -d "$DOCKER_DIR/apps/$APP/scripts" ]; then
            DEST_DIR="$BASE_DEST_PATH/$APP"
            echo -e "${YELLOW}Creating directory: $DEST_DIR${NC}"
            mkdir -p "$DEST_DIR"
            echo -e "${GREEN}Copying scripts from $DOCKER_DIR/apps/$APP/scripts to $DEST_DIR${NC}"
            # Temporarily enable:
            # - dotglob: include hidden files in wildcard matches
            # - nullglob: expand to empty string if no matches found
            shopt -s dotglob nullglob
            cp -r "$DOCKER_DIR/apps/$APP/scripts"/* "$DEST_DIR/" 2>/dev/null || true
            # Reset shell options to their original state
            shopt -u dotglob nullglob
        else
            echo -e "${RED}No scripts directory found for application: $APP${NC}"
        fi
    done
}

# Execute the copy function
copy_scripts