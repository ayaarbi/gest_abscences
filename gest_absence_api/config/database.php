<?php
// Autorise les appels depuis Flutter (CORS)
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

function getConnection() {
    $host = "127.0.0.1";
    $db   = "gest_absence";
    $port = '3307';
    $user = "root";
    $pass = "";          

    $conn = new mysqli($host, $user, $pass, $db,$port);
    $conn->set_charset("utf8mb4");

    if ($conn->connect_error) {
        echo json_encode(["success" => 0, "message" => "Connexion DB echoue ! "]);
        exit();
    }
    return $conn;
}
?>