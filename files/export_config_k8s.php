#!/usr/bin/env php
<?php

/**
 * Export Observium Config to base64
 *
 * @subpackage cli
 * @author     Pablo Vargas <pablo@pampa.cloud>
 * @copyright  GNU GPL v3.0
 *
 *
 * Use:
 *    php export_config_k8s.php | base64 -d
 */

chdir(dirname($argv[0]));
$scriptname = basename($argv[0]);

include("includes/sql-config.inc.php");

if (OBS_DEBUG) { print_versions(); }

function export_config($base,$array) {
        foreach($array as $name => $value) {
        if (is_array($value)) {
                $newbase = $base.$name.'][';
                export_config($newbase,$value);
        } else {
                echo base64_encode("$base$name]=\"$value\"; \n");
        }
    }

}

$export=get_defined_settings();

#print_r($export);
export_config('$config[',$export);

echo "\n"
// EOF
?>
