#!/bin/bash

# Setup logging colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

function parse_yaml {
  local yaml_file=$1
  
  echo -e "${YELLOW}Debug: Attempting to parse file: $yaml_file${NC}"
  
  # Use -r to get raw output (no quotes)
  NFS_SERVER=$(yq -r '.NFS_SERVER' "$yaml_file")
  NFS_PATH_BASE=$(yq -r '.NFS_PATH_BASE' "$yaml_file")
  readarray -t VOLUME_NAMES < <(yq -r '.VOLUME_NAMES[]' "$yaml_file")
  OPTION=$(yq -r '.OPTION' "$yaml_file")
  BIND_PATH=$(yq -r '.BIND_PATH' "$yaml_file")
  APP_NAME=$(yq -r '.APP_NAME' "$yaml_file")
  
  # Debug output
  echo -e "${YELLOW}Debug values:${NC}"
  echo -e "NFS_SERVER='$NFS_SERVER'"
  echo -e "NFS_PATH_BASE='$NFS_PATH_BASE'"
  echo -e "VOLUME_NAMES='${VOLUME_NAMES[*]}'"
  echo -e "OPTION='$OPTION'"
  echo -e "BIND_PATH='$BIND_PATH'"
  echo -e "APP_NAME='$APP_NAME'"
  echo -e "${NC}"
}

function remove_volumes() {
    for VOLUME_NAME in "${VOLUME_NAMES[@]}"; do
        # Check if volume exists
        if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
            echo -e "${YELLOW}Volume $VOLUME_NAME does not exist. Skipping.${NC}"
            echo
            continue
        fi

        # Show current configuration before removal
        echo -e "${YELLOW}Current configuration for volume $VOLUME_NAME:${NC}"
        echo -e "Type: $(docker volume inspect "$VOLUME_NAME" --format '{{.Options.type}}')"
        echo -e "Device: $(docker volume inspect "$VOLUME_NAME" --format '{{.Options.device}}')"
        if [ "$(docker volume inspect "$VOLUME_NAME" --format '{{.Options.type}}')" = "nfs" ]; then
            echo -e "Mount options: $(docker volume inspect "$VOLUME_NAME" --format '{{.Options.o}}')"
        fi

        # Check if volume is in use by any container
        if docker ps -a --filter volume="$VOLUME_NAME" -q | grep -q .; then
            echo -e "${RED}Volume $VOLUME_NAME is currently in use by containers:${NC}"
            docker ps -a --filter volume="$VOLUME_NAME" --format "{{.Names}}"
            echo -e "${RED}Please stop and remove these containers before removing the volume.${NC}"
            echo
            continue
        fi

        # Remove the volume
        echo -e "${YELLOW}Removing volume: $VOLUME_NAME${NC}"
        if docker volume rm "$VOLUME_NAME"; then
            echo -e "${GREEN}Successfully removed volume: $VOLUME_NAME${NC}"
        else
            echo -e "${RED}Failed to remove volume: $VOLUME_NAME${NC}"
        fi
        echo
    done
}

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo -e "${RED}yq is not installed. Installing yq...${NC}"
    sudo apt-get update && sudo apt-get install -y yq
fi

# Check if config file is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No config file provided${NC}"
    echo -e "Usage: $0 <config_file_path>"
    exit 1
fi

# Check if config file exists
if [ ! -f "$1" ]; then
    echo -e "${RED}Error: Config file not found: $1${NC}"
    exit 1
fi

# Load configuration
parse_yaml "$1"

# Make variables available to the rest of the script
export NFS_SERVER
export NFS_PATH_BASE
export VOLUME_NAMES
export OPTION
export BIND_PATH
export APP_NAME

# Verify VOLUME_NAMES is not empty
if [ ${#VOLUME_NAMES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No volumes specified in config file${NC}"
    exit 1
fi

# Remove volumes
remove_volumes
