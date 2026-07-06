#!/bin/sh

BACKUP_DIR="/backup/config"

if [ -z "$1" ]; then
    logger -t local-backup "Error: No backup filename provided for delete"
    exit 1
fi

FILENAME=$(basename "$1")
BACKUP_FILE="${BACKUP_DIR}/${FILENAME}"

if [ -f "$BACKUP_FILE" ]; then
    rm "$BACKUP_FILE"
    if [ $? -eq 0 ]; then
        logger -t local-backup "Backup deleted: $FILENAME"
        echo "OK"
        exit 0
    else
        logger -t local-backup "Error: Failed to delete backup $FILENAME (Return code: $?)"
        exit 1
    fi
else
    logger -t local-backup "Error: Backup file $BACKUP_FILE not found"
    exit 1
fi
