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
  readarray -t VOLUME_NAMES < <(yq -r '.VOLUME_NAMES[]' "$yaml_file")
  
  # Debug output
  echo -e "${YELLOW}Debug values:${NC}"
  echo -e "VOLUME_NAMES='${VOLUME_NAMES[*]}'"
}

function inspect_volumes() {
    for VOLUME_NAME in "${VOLUME_NAMES[@]}"; do
        # Check if volume exists
        if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
            echo -e "${YELLOW}Volume $VOLUME_NAME does not exist. Skipping.${NC}"
            echo
            continue
        fi

        # Show current configuration
        echo -e "${YELLOW}Current configuration for volume $VOLUME_NAME:${NC}"
        echo -e "Type: $(docker volume inspect "$VOLUME_NAME" --format '{{.Options.type}}')"
        echo -e "Option: $(docker volume inspect "$VOLUME_NAME" --format '{{.Options.o}}')"
        echo -e "Device: $(docker volume inspect "$VOLUME_NAME" --format '{{.Options.device}}')"
        if [ "$(docker volume inspect "$VOLUME_NAME" --format '{{.Options.type}}')" = "nfs" ]; then
            echo -e "Mount options: $(docker volume inspect "$VOLUME_NAME" --format '{{.Options.o}}')"
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

# Inspect volumes
inspect_volumes
