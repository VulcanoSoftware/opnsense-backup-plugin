#!/bin/sh

BACKUP_DIR="/backup/config"
MIN_FREE_GB=${1:-10}

# Validate that MIN_FREE_GB is a positive integer
if ! echo "$MIN_FREE_GB" | grep -qE '^[0-9]+$'; then
    logger -t local-backup "Cleanup Error: Invalid minimum free space value '$MIN_FREE_GB'. Defaulting to 10GB."
    MIN_FREE_GB=10
fi

MIN_FREE_KB=$((MIN_FREE_GB * 1024 * 1024))

if [ ! -d "$BACKUP_DIR" ]; then
    exit 0
fi

check_free_space() {
    # Get available space in KB for the filesystem containing BACKUP_DIR
    df -k "$BACKUP_DIR" | tail -1 | awk '{print $4}'
}

FREE_KB=$(check_free_space)

while [ "$FREE_KB" -lt "$MIN_FREE_KB" ]; do
    # Find oldest backup
    OLDEST=$(ls -tr "${BACKUP_DIR}"/config-*.xml 2>/dev/null | head -1)

    if [ -z "$OLDEST" ]; then
        logger -t local-backup "Cleanup: No more backups to delete, but space is still low."
        break
    fi

    FILENAME=$(basename "$OLDEST")
    rm "$OLDEST"
    if [ $? -eq 0 ]; then
        logger -t local-backup "Cleanup removed old backup: $FILENAME"
    else
        logger -t local-backup "Error: Failed to remove old backup: $FILENAME (Return code: $?)"
        break
    fi

    FREE_KB=$(check_free_space)
done

echo "OK"
exit 0
