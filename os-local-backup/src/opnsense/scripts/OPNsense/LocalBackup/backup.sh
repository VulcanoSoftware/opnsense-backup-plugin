#!/bin/sh

BACKUP_DIR="/backup/config"
SOURCE_CONFIG="/conf/config.xml"
DATE=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/config-${DATE}.xml"

# Ensure backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        logger -t local-backup "Error: Could not create backup directory $BACKUP_DIR"
        exit 1
    fi
    chmod 755 "$BACKUP_DIR"
fi

# Check if source exists
if [ ! -f "$SOURCE_CONFIG" ]; then
    logger -t local-backup "Error: Source config $SOURCE_CONFIG not found"
    exit 1
fi

# Copy config
cp "$SOURCE_CONFIG" "$BACKUP_FILE"
if [ $? -eq 0 ]; then
    chmod 644 "$BACKUP_FILE"
    sync
    logger -t local-backup "Backup created: $(basename $BACKUP_FILE)"
    echo "OK"
    exit 0
else
    logger -t local-backup "Error: Failed to copy $SOURCE_CONFIG to $BACKUP_FILE (Return code: $?)"
    exit 1
fi
