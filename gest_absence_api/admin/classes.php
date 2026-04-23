<?php
require_once '../config/database.php';
$conn = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $result = $conn->query("SELECT * FROM classes");

    if (!$result) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des classes"]);
    } else {
        $list = [];
        while ($row = $result->fetch_assoc()) $list[] = $row;
        echo json_encode(["success" => 1, "data" => $list]);
    }

} elseif ($method === 'POST') {
    $d = json_decode(file_get_contents("php://input"), true);

    if (empty($d['nom'])) {
        echo json_encode(["success" => 0, "message" => "Le nom de la classe est requis"]);
        exit();
    }

    $stmt = $conn->prepare("INSERT INTO classes (nom, niveau) VALUES (?,?)");

    if (!$stmt) {
        echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL"]);
        exit();
    }

    $stmt->bind_param("ss", $d['nom'], $d['niveau']);

    if (!$stmt->execute()) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de l'ajout de la classe"]);
    } else {
        echo json_encode(["success" => 1, "message" => "Classe ajoutée avec succès"]);
    }

} else {
    echo json_encode(["success" => 0, "message" => "Méthode non autorisée"]);
}

$conn->close();
?>