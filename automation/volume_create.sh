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

function create_volumes_nfs() {
    for VOLUME_NAME in "${VOLUME_NAMES[@]}"; do
        NFS_PATH="$NFS_PATH_BASE/$VOLUME_NAME"
        
        # Check if volume exists
        if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
            echo -e "${YELLOW}Volume $VOLUME_NAME already exists. Current configuration:${NC}"
            docker volume inspect "$VOLUME_NAME" --format '{{.Options.o}}'
            docker volume inspect "$VOLUME_NAME" --format '{{.Options.type}}'
            docker volume inspect "$VOLUME_NAME" --format '{{.Options.device}}'
            echo -e "${YELLOW}Skipping volume creation.${NC}"
            echo
            continue
        fi
        
        echo -e "${GREEN}Creating NFS volume: $NFS_SERVER:$NFS_PATH${NC}"
        docker volume create \
            --driver local \
            --opt type=nfs \
            --opt o=addr=$NFS_SERVER,vers=4,rw \
            --opt device=:$NFS_PATH \
            $VOLUME_NAME
        echo -e "${GREEN}Volume created: $VOLUME_NAME${NC}"
    done
}

function create_volumes_bind() {
    for VOLUME_NAME in "${VOLUME_NAMES[@]}"; do
        # Check if volume exists
        if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
            echo -e "${YELLOW}Volume $VOLUME_NAME already exists. Current configuration:${NC}"
            docker volume inspect "$VOLUME_NAME" --format '{{.Options.o}}'
            docker volume inspect "$VOLUME_NAME" --format '{{.Options.type}}'
            docker volume inspect "$VOLUME_NAME" --format '{{.Options.device}}'
            echo -e "${YELLOW}Skipping volume creation.${NC}"
            echo
            continue
        fi
        
        echo -e "${GREEN}Creating bind volume: $BIND_PATH/$VOLUME_NAME${NC}"
        docker volume create \
            --driver local \
            --opt type=none \
            --opt device=$BIND_PATH/$VOLUME_NAME \
            --opt o=bind \
            $VOLUME_NAME
        echo -e "${GREEN}Volume created: $VOLUME_NAME${NC}"
    done
}

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo -e "${RED}yq is not installed. Installing yq...${NC}"
    sudo apt-get update && sudo apt-get install -y yq
fi

# Load configuration and export variables
parse_yaml "$1"

# # Make variables available to the rest of the script
export NFS_SERVER
export NFS_PATH_BASE
export VOLUME_NAMES
export OPTION
export BIND_PATH
export APP_NAME

if [ "$OPTION" = "nfs" ]; then
  if [ -n "$NFS_PATH_BASE" ]; then
    create_volumes_nfs
  else
    echo -e "${RED}No NFS_PATH_BASE specified in config.yaml. Skipping volume creation. Exiting.${NC}" >&2
    exit 1
  fi
elif [ "$OPTION" = "bind" ]; then
  if [ -n "$BIND_PATH" ]; then
    create_volumes_bind
  else
    echo -e "${RED}No BIND_PATH specified in config.yaml. Skipping volume creation. Exiting.${NC}" >&2
    exit 1
  fi
else
  echo -e "${RED}No OPTION specified in config.yaml. Skipping volume creation. Exiting.${NC}" >&2
  exit 1
fi