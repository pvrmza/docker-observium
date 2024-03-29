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
 *    php ./export_config_ALLCONFIG.php | base64 
 */

chdir(dirname($argv[0]));
$scriptname = basename($argv[0]);

include("includes/sql-config.inc.php");

if (OBS_DEBUG) { print_versions(); }

function export_config($base,$array) {
        foreach($array as $name => $value) {
                if (is_array($value)) {
                        $newbase = $base.$name."']['";
                        export_config($newbase,$value);
                } else {
                        if ( (is_numeric($value)) || (is_bool($value)) ) {
                                print("$base$name']=$value; \n");
                        } else {
                                print("$base$name']=\"$value\"; \n");
                        }
                }
        }

}

$export=get_defined_settings();

export_config("\$config['",$export);

?>
