#!/bin/bash

#####################################################################################################################
# Author: Tulon Baar                                                                                                #
# Last update: 12.01.2024                                                                                           #
# Description: Script that creates volumes specified in VOLUME_NAMES for a given node                               #
# I recommend using the send_scripts.sh script to send this script to multiple target machines                      #
# Warnings: If they already exist - it won't create new ones, Setting SSH Keys is necessary                         #
#####################################################################################################################

# Array of volume names
VOLUME_NAMES=("nominatim-data" "postgres-data" "osrm-fast-data" "osrm-short-data")

# Data for NFS
NFS_SERVER="<IP>"
APP_NAME="osm"
NFS_PATH_BASE="/hua-shared/$APP_NAME/volumes"

# Check if NFS_SERVER is set to the default placeholder
if [ "$NFS_SERVER" == "<IP>" ]; then
  echo "NFS_SERVER is set to the default placeholder. Please enter the IP address of the NFS server:"
  read NFS_SERVER
fi

# Iterate through all volume names
for VOLUME_NAME in "${VOLUME_NAMES[@]}"; do
  # Create NFS path
  NFS_PATH="$NFS_PATH_BASE/$VOLUME_NAME"

  # Create volume with NFS mount
  echo "Creating volume with NFS mount: $NFS_SERVER:$NFS_PATH"
  docker volume create \
    --driver local \
    --opt type=nfs \
    --opt o=addr=$NFS_SERVER,vers=4,rw \
    --opt device=:$NFS_PATH \
    $VOLUME_NAME

  echo "Volume created: $VOLUME_NAME"
done
