<?php
/**
 * Database Configuration
 *
 * Defaults to the variables in a Porter Postgres datastore's environment group
 * (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS). Any CRAFT_DB_* environment
 * variable takes precedence over the value set here.
 *
 * @link https://craftcms.com/docs/5.x/reference/config/db.html
 */

use craft\helpers\App;

return array_filter([
    'driver' => 'pgsql',
    'server' => App::env('DB_HOST'),
    'port' => App::env('DB_PORT'),
    'database' => App::env('DB_NAME'),
    'user' => App::env('DB_USER'),
    'password' => App::env('DB_PASS'),
], fn($value) => $value !== null);
