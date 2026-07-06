<?php

namespace OPNsense\LocalBackup\Api;

use OPNsense\Base\ApiMutableModelControllerBase;

class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'LocalBackup';
    protected static $internalModelClass = 'OPNsense\LocalBackup\LocalBackup';
}
