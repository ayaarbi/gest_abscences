<?php
require_once '../config/database.php';
$conn = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $result = $conn->query("SELECT * FROM matieres");

    if (!$result) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des matières"]);
    } else {
        $list = [];
        while ($row = $result->fetch_assoc()) {
            $list[] = $row;
        }
        echo json_encode(["success" => 1, "data" => $list]);
    }
}
$conn->close();
?>