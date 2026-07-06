<?php

$backup_dir = "/backup/config";
$backups = [];

if (is_dir($backup_dir)) {
    foreach (glob($backup_dir . "/config-*.xml") as $filename) {
        $backups[] = [
            "filename" => basename($filename),
            "size" => filesize($filename),
            "date" => date("Y-m-d H:i:s", filemtime($filename)),
            "mtime" => filemtime($filename)
        ];
    }
}

// Sort newest first
usort($backups, function ($a, $b) {
    return $b['mtime'] - $a['mtime'];
});

// Remove mtime from output
array_walk($backups, function (&$item) {
    unset($item['mtime']);
});

// Get disk space info
$total_space = disk_total_space($backup_dir) ?: 0;
$free_space = disk_free_space($backup_dir) ?: 0;

echo json_encode([
    "backups" => $backups,
    "free_space" => $free_space,
    "total_space" => $total_space,
    "location" => $backup_dir,
    "count" => count($backups)
]);
