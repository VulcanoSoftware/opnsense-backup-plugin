<?php

namespace OPNsense\LocalBackup;

use OPNsense\Base\IndexController as BaseIndexController;

class IndexController extends BaseIndexController
{
    public function indexAction()
    {
        $this->view->title = gettext("Local Backups");
        $this->view->generalForm = $this->getForm("general");
        $this->view->pick('OPNsense/LocalBackup/index');
    }
}
