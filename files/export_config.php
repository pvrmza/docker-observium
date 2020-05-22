#!/usr/bin/env php
<?php

/**
 * Export Observium Config
 *
 * @subpackage cli
 * @author     Pablo Vargas <pablo@pampa.cloud>
 * @copyright  GNU GPL v3.0
 *
 */

chdir(dirname($argv[0]));
$scriptname = basename($argv[0]);

include("includes/sql-config.inc.php");

if (OBS_DEBUG) { print_versions(); }

function export_config($base,$array) {
        foreach($array as $name => $value) {
        if (is_array($value)) {
                $newbase = $base.$name.'__';
                export_config($newbase,$value);
        } else {
                echo "$base$name=\"$value\" \n";
        }
    }
}

$export=get_defined_settings();
export_config("OBSERVIUM_",$export);

// EOF
?>
