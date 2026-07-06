#!/bin/sh

BACKUP_DIR=${1:-"/backup/config"}

if [ -z "$2" ]; then
    logger -t local-backup "Error: No backup filename provided for delete"
    exit 1
fi

FILENAME=$(basename "$2")
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
