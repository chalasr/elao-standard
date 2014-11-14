<?php

/*
 * This file is part of the Symfony package.
 *
 * (c) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace SymfonyStandard;

use Composer\EventDispatcher\EventSubscriberInterface;
use Composer\Script\ScriptEvents;
use Composer\Script\CommandEvent;
use Sensio\Bundle\DistributionBundle\Composer\ScriptHandler;

class RootPackageInstallSubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents()
    {
        return array(
            ScriptEvents::PRE_INSTALL_CMD => array(
                array('overrideProjectName', 512),
            ),
        );
    }

    public static function overrideProjectName(CommandEvent $event)
    {
        $projectName = $event->getIO()->ask('Project name ?', 'symfony-project');
        $vendorName = $event->getIO()->ask('vendor name ?', '');

        $files = [
            'Vagrantfile',
            'app/config/parameters.yml.dist',
            'package.json',
            'bower.json',
            'ansible/group_vars/all',
            'ansible/group_vars/dev',
        ];

        $vars = [
            '{{ projectName }}' => $projectName,
            '{{ vendorName }}' => $vendorName,
        ];

        foreach ($files as $file) {
            if (file_exists($file)) {
                $content = file_get_contents($file);

                $content = strtr($content, $vars);

                file_put_contents($file, $content);
            }
        }

        // change the project name in composer
        $composerName = $vendorName ? $vendorName . '/' . $projectName : $projectName;

        $content = file_get_contents('composer.json');

        $content = strtr($content, ['elao/symfony-standard' => $composerName]);

        file_put_contents('composer.json', $content);
    }
}
