#!/bin/sh

BACKUP_DIR="/backup/config"
SOURCE_CONFIG="/conf/config.xml"

if [ -z "$1" ]; then
    logger -t local-backup "Error: No backup filename provided for restore"
    exit 1
fi

FILENAME=$(basename "$1")
BACKUP_FILE="${BACKUP_DIR}/${FILENAME}"

# Validate path to prevent traversal
if [ ! -f "$BACKUP_FILE" ]; then
    logger -t local-backup "Error: Backup file $BACKUP_FILE not found"
    exit 1
fi

# Restore config
cp "$BACKUP_FILE" "$SOURCE_CONFIG"
if [ $? -eq 0 ]; then
    logger -t local-backup "Backup restored: $FILENAME. Rebooting..."
    echo "OK"
    # Schedule reboot
    /usr/local/sbin/configctl system reboot
    exit 0
else
    logger -t local-backup "Error: Failed to restore backup $FILENAME"
    exit 1
fi
