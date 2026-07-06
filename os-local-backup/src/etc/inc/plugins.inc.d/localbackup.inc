<?php

function localbackup_cron_jobs()
{
    $jobs = array();
    $model = new \OPNsense\LocalBackup\LocalBackup();
    if ((string)$model->general->enabled == "1") {
        $min_free = (string)$model->general->min_free_space ?: "10";
        $jobs[] = array(
            "description" => "Local configuration backup",
            "command" => "localbackup backup",
            "minute" => (string)$model->general->minute,
            "hour" => (string)$model->general->hour,
            "day" => "*",
            "month" => "*",
            "weekday" => "*"
        );
        $jobs[] = array(
            "description" => "Local backup cleanup",
            "command" => "localbackup cleanup " . $min_free,
            "minute" => (string)$model->general->minute,
            "hour" => (string)$model->general->hour,
            "day" => "*",
            "month" => "*",
            "weekday" => "*"
        );
    }
    return $jobs;
}
