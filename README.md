# OPNsense Local Backup Plugin

This plugin provides a simple way to create and manage local configuration backups on OPNsense. It is specifically designed to store backups on a dedicated local path (e.g., a mounted mechanical drive or a separate partition) to avoid unnecessary write cycles on the system SSD.

## Features

- **Automatic Daily Backups:** Configure a specific time for daily backups.
- **Manual Backups:** Create a backup at any time from the web interface.
- **Backup Management:** List, download, restore, and delete backups from the UI.
- **Automatic Cleanup:** Automatically deletes the oldest backups when disk space on the backup path falls below a configurable threshold. This ensures the backup destination never runs out of space.
- **Safety First:** Restoring a backup automatically triggers a system reboot to ensure the configuration is applied cleanly and all services are correctly initialized with the restored settings.

## Requirements

- **Backup Path:** The plugin stores backups in `/backup/config`. You should ensure this directory is either on a separate partition or a mounted external drive. The plugin will attempt to create the directory if it doesn't exist.

## Installation

1. Copy the plugin files to your OPNsense system.
2. Run `make install` from the plugin directory or install via the OPNsense package manager if available.
3. Refresh the OPNsense UI.
4. Navigate to **System -> Local Backups** to configure and use the plugin.

## Configuration

- **Enable automatic backups:** Toggle the daily backup schedule.
- **Hour/Minute:** Set the time for the automatic backup.
- **Keep minimum free space (GB):** The plugin will ensure at least this much space remains on the backup disk by deleting old backups.
- **Backup path:** Specify the absolute path to the backup directory. It is recommended to use a path that points to a separate physical disk or partition.

## License

This project is licensed under the BSD 2-Clause License. See the [LICENSE](LICENSE) file for details.
