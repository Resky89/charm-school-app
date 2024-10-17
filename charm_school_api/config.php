<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

$host = "localhost";
$user = "root";
$pass = "";
$db   = "charm_school";

// $host = "localhost";
// $user = "Ojan";
// $pass = "daytt123*363#";
// $db   = "praktikum_ti_2022_KLPK_Ojan";

$connection = mysqli_connect($host, $user, $pass, $db);

if ($connection->connect_error) {
    die("Koneksi gagal: " . $connection->connect_error);
}