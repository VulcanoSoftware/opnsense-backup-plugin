<?php

namespace OPNsense\LocalBackup\Api;

use OPNsense\Base\ApiControllerBase;
use OPNsense\Core\Backend;
use OPNsense\LocalBackup\LocalBackup;

class ServiceController extends ApiControllerBase
{
    public function backupAction()
    {
        $backend = new Backend();
        $response = $backend->configdRun('localbackup backup');
        return ["status" => $response];
    }

    public function restoreAction($filename = null)
    {
        if ($filename !== null) {
            $backend = new Backend();
            $filename = basename($filename);
            $response = $backend->configdRun("localbackup restore ${filename}");
            return ["status" => $response];
        }
        return ["status" => "error", "message" => "No filename provided"];
    }

    public function listAction()
    {
        $backend = new Backend();
        $response = $backend->configdRun('localbackup list');
        return json_decode($response, true);
    }

    public function deleteAction($filename = null)
    {
        if ($filename !== null) {
            $backend = new Backend();
            $filename = basename($filename);
            $response = $backend->configdRun("localbackup delete ${filename}");
            return ["status" => $response];
        }
        return ["status" => "error", "message" => "No filename provided"];
    }

    public function cleanupAction()
    {
        $backend = new Backend();
        $model = new LocalBackup();
        $min_free = (string)$model->general->min_free_space ?: "10";
        $response = $backend->configdRun("localbackup cleanup ${min_free}");
        return ["status" => $response];
    }

    public function downloadAction($filename = null)
    {
        if ($filename !== null) {
            $filename = basename($filename);
            $filepath = "/backup/config/" . $filename;
            if (file_exists($filepath)) {
                $content = file_get_contents($filepath);
                header('Content-Type: application/xml');
                header('Content-Disposition: attachment; filename="' . $filename . '"');
                header('Content-Length: ' . strlen($content));
                echo $content;
                exit;
            }
        }
        return ["status" => "error", "message" => "File not found"];
    }
}
