<?php

function localbackup_cron_jobs()
{
    $jobs = array();
    $model = new \OPNsense\LocalBackup\LocalBackup();
    if ((string)$model->general->enabled == "1") {
        $min_free = (string)$model->general->min_free_space ?: "10";
        $path = (string)$model->general->backup_path ?: "/backup/config";
        $jobs[] = array(
            "description" => "Local configuration backup",
            "command" => "localbackup backup " . $path,
            "minute" => (string)$model->general->minute,
            "hour" => (string)$model->general->hour,
            "day" => "*",
            "month" => "*",
            "weekday" => "*"
        );

        // Stagger cleanup 5 minutes after backup
        $cleanup_minute = ((int)$model->general->minute + 5) % 60;
        $cleanup_hour = (int)$model->general->hour;
        if ((int)$model->general->minute + 5 >= 60) {
            $cleanup_hour = ($cleanup_hour + 1) % 24;
        }

        $jobs[] = array(
            "description" => "Local backup cleanup",
            "command" => "localbackup cleanup " . $path . " " . $min_free,
            "minute" => (string)$cleanup_minute,
            "hour" => (string)$cleanup_hour,
            "day" => "*",
            "month" => "*",
            "weekday" => "*"
        );
    }
    return $jobs;
}
