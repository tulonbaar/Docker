#!/bin/bash

#####################################################################################################################
# Author: Tulon Baar                                                                                                #
# Last update: 12.01.2024                                                                                           #
# Description: Script that removes the volumes specified in VOLUMES_TO_DELETE from a given node                     #
# I recommend using the send_scripts.sh script to send this script to multiple target machines                      #
# Warnings: If they don't exist - it won't delete any, Setting SSH Keys is necessary                                #
#####################################################################################################################

# Array of volume names you want to delete
VOLUMES_TO_DELETE=("nominatim-data" "postgres-data" "osrm-fast-data" "osrm-short-data")

# Get all existing volume names
EXISTING_VOLUMES=$(docker volume ls -q)

# Iterate through each definition name to delete
for VOLUME in "${VOLUMES_TO_DELETE[@]}"; do
  if echo "$EXISTING_VOLUMES" | grep -wq "$VOLUME"; then
    echo "Removing volume: $VOLUME"
    docker volume rm "$VOLUME"
  else
    echo "Volume $VOLUME does not exist or has already been removed."
  fi
done
