<?php

namespace OPNsense\LocalBackup\Api;

use OPNsense\Base\ApiControllerBase;
use OPNsense\Core\Backend;
use OPNsense\LocalBackup\LocalBackup;

class ServiceController extends ApiControllerBase
{
    private function getBackupPath()
    {
        $model = new LocalBackup();
        return (string)$model->general->backup_path ?: "/backup/config";
    }

    public function backupAction()
    {
        $backend = new Backend();
        $path = $this->getBackupPath();
        $response = $backend->configdRun("localbackup backup {$path}");
        return ["status" => $response];
    }

    public function restoreAction($filename = null)
    {
        if ($filename !== null) {
            $filename = basename($filename);
            if (str_starts_with($filename, 'config-') && str_ends_with($filename, '.xml')) {
                $backend = new Backend();
                $path = $this->getBackupPath();
                $response = $backend->configdRun("localbackup restore {$path} {$filename}");
                return ["status" => $response];
            }
        }
        return ["status" => "error", "message" => "No filename provided or invalid filename"];
    }

    public function listAction()
    {
        $backend = new Backend();
        $path = $this->getBackupPath();
        $response = $backend->configdRun("localbackup list {$path}");
        $data = json_decode($response, true);
        if ($data === null) {
            return ["backups" => [], "count" => 0, "status" => "error"];
        }
        return $data;
    }

    public function deleteAction($filename = null)
    {
        if ($filename !== null) {
            $filename = basename($filename);
            if (str_starts_with($filename, 'config-') && str_ends_with($filename, '.xml')) {
                $backend = new Backend();
                $path = $this->getBackupPath();
                $response = $backend->configdRun("localbackup delete {$path} {$filename}");
                return ["status" => $response];
            }
        }
        return ["status" => "error", "message" => "No filename provided or invalid filename"];
    }

    public function cleanupAction()
    {
        $backend = new Backend();
        $model = new LocalBackup();
        $min_free = (string)$model->general->min_free_space ?: "10";
        $path = $this->getBackupPath();
        $response = $backend->configdRun("localbackup cleanup {$path} {$min_free}");
        return ["status" => $response];
    }

    public function reconfigureAction()
    {
        $backend = new Backend();
        $response = $backend->configdRun('localbackup reconfigure');
        return ["status" => $response];
    }

    public function downloadAction($filename = null)
    {
        if ($filename !== null) {
            $filename = basename($filename);
            $path = $this->getBackupPath();
            $filepath = $path . "/" . $filename;
            if (str_starts_with($filename, 'config-') && str_ends_with($filename, '.xml') && file_exists($filepath)) {
                while (ob_get_level()) {
                    ob_end_clean();
                }
                header('Content-Type: application/xml');
                header('Content-Disposition: attachment; filename="' . $filename . '"');
                header('Content-Length: ' . filesize($filepath));
                header('Pragma: public');
                header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
                readfile($filepath);
                exit;
            }
        }
        return ["status" => "error", "message" => "File not found"];
    }
}
