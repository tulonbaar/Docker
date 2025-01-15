#!/bin/bash

install_deps() {
    apt-get update && apt-get install -y wget osmium-tool bc
}


# Directory where the maps are stored
MAP_DIR="/mapy"
BACKUP_DIR="/backup"

# List of map files to check and download
MAP_FILES=(
    "austria-latest.osm.pbf"
    "czech-republic-latest.osm.pbf"
    "germany-latest.osm.pbf"
    "hungary-latest.osm.pbf"
    "lithuania-latest.osm.pbf"
    "poland-latest.osm.pbf"
    "slovakia-latest.osm.pbf"
)

# Function to download maps
download_maps() {
    echo -e "\nDownloading new map files...\n"
    for MAP_FILE in "${MAP_FILES[@]}"; do
        wget -P "$MAP_DIR" "https://download.geofabrik.de/europe/$MAP_FILE"
    done
}

# Function to backup maps
backup_maps() {
    echo -e "\nBacking up map files...\n"
    for MAP_FILE in "${MAP_FILES[@]}"; do
        cp "$MAP_DIR/$MAP_FILE" "$BACKUP_DIR/$MAP_FILE"
    done
}

# Check if files exist and take action
check_and_download_maps() {
    local return_code=0
    for MAP_FILE in "${MAP_FILES[@]}"; do
        if [ ! -f "$MAP_DIR/$MAP_FILE" ]; then
            echo "File $MAP_FILE not found, downloading..."
            download_maps
            return_code=1
        else
            local MAP_FILE_MOD_DATE=$(stat -c "%Y" "$MAP_DIR/$MAP_FILE")
            local CURRENT_DATE=$(date +%s)
            local DIFF_IN_DAYS=$(echo "scale=0; ($CURRENT_DATE - $MAP_FILE_MOD_DATE) / (60 * 60 * 24)" | bc)
            if [ $DIFF_IN_DAYS -gt 7 ]; then
                echo "File $MAP_FILE is older than 7 days, downloading..."
                backup_maps
                download_maps
                return_code=1
            else
                echo "File $MAP_FILE is newer than 7 days, skipping..."
                return_code=1
            fi
        fi
    done
    return $return_code
}

merge_maps() {
    local MERGED_FILE="$MAP_DIR/AU_CZ_DE_HU_LI_PL_SK.osm.pbf"

    if [ ! -f "$MERGED_FILE" ]; then
        echo "File $MERGED_FILE not found, merging..."
    else
        local MERGED_FILE_MOD_DATE=$(stat -c "%Y" "$MERGED_FILE")
        local CURRENT_DATE=$(date +%s)
        local DIFF_IN_DAYS=$(echo "scale=0; ($CURRENT_DATE - $MERGED_FILE_MOD_DATE) / (60 * 60 * 24)" | bc)

        if [ $DIFF_IN_DAYS -gt 7 ]; then
            echo "File $MERGED_FILE is older than 7 days, merging..."
        else
            echo "File $MERGED_FILE is newer than 7 days, skipping..."
            exit 0
        fi
    fi

    if [ -f "$MERGED_FILE" ]; then
        local BACKUP_MERGED_FILE="$BACKUP_DIR/merged/$(date +%Y-%m-%d).osm.pbf"
        echo "Moving existing merged file to $BACKUP_MERGED_FILE..."
        mv "$MERGED_FILE" "$BACKUP_MERGED_FILE"
    fi

    echo -e "\nMerge new maps to one map\n"
    osmium merge \
        "$MAP_DIR/slovakia-latest.osm.pbf" \
        "$MAP_DIR/poland-latest.osm.pbf" \
        "$MAP_DIR/lithuania-latest.osm.pbf" \
        "$MAP_DIR/hungary-latest.osm.pbf" \
        "$MAP_DIR/germany-latest.osm.pbf" \
        "$MAP_DIR/czech-republic-latest.osm.pbf" \
        "$MAP_DIR/austria-latest.osm.pbf" \
        -o "$MERGED_FILE"
}

clean_maps_folder() {
    echo "Cleaning maps folder..."
    rm -rf "$MAP_DIR"/*
}

# Main script

# Check if dependencies are present
if ! which wget > /dev/null || ! which osmium-tool > /dev/null || ! which bc > /dev/null; then
    echo "Wget, osmium-tool or bc not found, installing dependencies..."
    install_deps
fi

if [ "$1" = "-force" ]; then
    echo "Forcing download and merge..."
    clean_maps_folder
    download_maps
    merge_maps
    exit 0
elif ! check_and_download_maps; then
    echo "No new maps to download. Merging existing maps..."
    merge_maps
    exit 0
fi


