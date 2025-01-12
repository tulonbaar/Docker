#!/bin/bash

#####################################################################################################################
# Author: Tulon Baar                                                                                                #
# Last update: 12.01.2024                                                                                           #
# Description: Script that sends a given script to machines in the HOSTS variable and runs it                       #
# Solution that allows to run a task on multiple machines at the "same" time                                        #
# Warnings: I use `node-user` naming in my SSH connections.                                                         #
#####################################################################################################################

# Define host names (assuming you have entries in ~/.ssh/config)
HOSTS=("dmaster-deploy" "dnode1-deploy" "dnode2-deploy")

# Check if the file name was provided as a parameter
if [ -z "$1" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

# File to be sent and run
FILE_NAME="$1"

# Check if the file exists
if [ ! -f "$FILE_NAME" ]; then
  echo "File $FILE_NAME does not exist."
  exit 1
fi

# Send and run the script on each resource
for HOST in "${HOSTS[@]}"; do
  echo "Sending and running script on $HOST"

  # Using explicit paths and handling SSH connections
  scp "$FILE_NAME" "$HOST:/tmp/script.sh"

  # Execute the script on the remote machine
  ssh "$HOST" 'sudo bash /tmp/script.sh'

  # Remove the script from the remote machine
  ssh "$HOST" 'sudo rm -f /tmp/script.sh'

done
