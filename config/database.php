<?php
declare(strict_types=1);

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$db = new mysqli(
    getenv('RDM_DB_HOST') ?: '127.0.0.1',
    getenv('RDM_DB_USER') ?: 'root',
    getenv('RDM_DB_PASSWORD') ?: '',
    getenv('RDM_DB_NAME') ?: 'rdm_lite',
    (int) (getenv('RDM_DB_PORT') ?: 3306)
);
$db->set_charset('utf8mb4');