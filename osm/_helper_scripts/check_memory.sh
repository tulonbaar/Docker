#!/bin/bash

#####################################################################################################################
# Author: Tulon Baar                                                                                                #
# Last update: 12.01.2024                                                                                           #
# Description: A script that displays information about memory usage in docker containers                           #
# I recommend using the send_scripts.sh script to send this script to multiple target machines                      #
# Warnings: Setting SSH Keys is necessary                                                                           #
#####################################################################################################################

echo "=== Docker Container Memory Usage ==="
echo

# Get container stats in a readable format
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.CPUPerc}}" | sort

echo
echo "=== Detailed Memory Information ==="
echo

for container in $(docker ps --format "{{.Names}}"); do
    echo "Container: $container"
    docker exec $container free -h 2>/dev/null || echo "free command not available"
    echo "---"
done

echo
echo "=== Docker Volume Sizes ==="
echo
docker system df -v | grep "osm"
