#!/bin/bash

#####################################################################################################################
# Author: Tulon Baar                                                                                                #
# Last update: 12.01.2024                                                                                           #
# Description: Script that cleans the given folder. Only files in subfolders will be deleted.                       #
#                                                                                                                   #
# Example of directory structure:                                                                                   #
#                                                                                                                   #
#           A                   <--- Parent directory (passed as a parameter)                                       #
#         / | \                                                                                                     #
#        /  |  \                                                                                                    #
#      A1  A2  A3               <--- Subdirectories, each of them will be processed                                 #
#     /|\  /|\  /|\                                                                                                 #
#    F1 F2 F3 F4 F5 F6          <--- Files and folders in subdirectories (will be deleted)                          #
#                                                                                                                   #
# Process of script operation:                                                                                      #
#                                                                                                                   #
# 1. User runs the script with parameter A (path to parent directory).                                              #
#                                                                                                                   #
# 2. Script checks if path A exists and is a directory.                                                             #
#   If not, an error message is displayed.                                                                          #
#                                                                                                                   #
# 3. Script iterates through each subdirectory of A (e.g. A1, A2, A3):                                              #
#   a. Enters A1                                                                                                    #
#      - Deletes all files and folders inside A1 (F1, F2, F3).                                                      #
#   b. Enters A2                                                                                                    #
#      - Deletes all files and folders inside A2 (F4, F5).                                                          #
#   c. Enters A3                                                                                                    #
#      - Deletes all files and folders inside A3 (F6).                                                              #
#                                                                                                                   #
# Final effect:                                                                                                     #
#                                                                                                                   #
#           A                                                                                                       #
#         / | \                                                                                                     #
#        /  |  \                                                                                                    #
#      A1  A2  A3               <--- Subdirectories still exist                                                     #
#       X   X   X               <--- Their content (F1, F2, ..., F6) was deleted                                    #
#                                                                                                                   #
# Warnings:                                                                                                         #
#####################################################################################################################


# Check if required parameter was passed
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_parent_directory>"
  exit 1
fi

# Save path to parent directory
PARENT_DIR="$1"

# Check if given path exists and is a directory
if [ ! -d "$PARENT_DIR" ]; then
  echo "Path $PARENT_DIR does not exist or is not a directory."
  exit 1
fi

# Iterate through subdirectories on one level
for DIR in "$PARENT_DIR"/*/; do
  # Check if subdirectories exist
  if [ -d "$DIR" ]; then
    echo "Cleaning: $DIR"
    # Delete all files and folders
    rm -rf "$DIR"/*
  fi
done