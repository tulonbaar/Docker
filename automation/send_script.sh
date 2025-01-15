#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <script_to_send> <config_file> [<destination_path>]"
    exit 1
fi

SCRIPT_TO_SEND=$1
CONFIG_FILE=$2
DESTINATION_PATH=${3:-"/tmp"}

# Define the target nodes (you can modify this list)
TARGET_NODES=($(jq -r '.docker_nodes[]' ./config/send_script.json))

# Function to send the script and config file to each node
send_files() {
    for NODE in "${TARGET_NODES[@]}"; do
        echo "Sending $SCRIPT_TO_SEND and $CONFIG_FILE to $NODE..."
        scp "$SCRIPT_TO_SEND" "$CONFIG_FILE" "$NODE:$DESTINATION_PATH"
        
        # Set DESTINATION_PATH as an environment variable and run the script on the target node
        ssh "$NODE" "export DESTINATION_PATH='$DESTINATION_PATH'; bash $DESTINATION_PATH/$(basename $SCRIPT_TO_SEND) $DESTINATION_PATH/$(basename $CONFIG_FILE)"
        # ssh "$NODE" "echo Debug: DESTINATION_PATH is: $DESTINATION_PATH"
    done
}

# Run the script on the target node
send_files

# Remove the script and config files from the target node
echo "Removing sent files..."
for NODE in "${TARGET_NODES[@]}"; do
    echo "Removing $SCRIPT_TO_SEND and $CONFIG_FILE from $NODE..."
    ssh "$NODE" "rm $DESTINATION_PATH/$(basename $SCRIPT_TO_SEND) $DESTINATION_PATH/$(basename $CONFIG_FILE)"
done
