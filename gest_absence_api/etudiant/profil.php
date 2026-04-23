<?php
require_once '../config/database.php';
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(["success" => 0, "message" => "Méthode non autorisée"]);
    exit();
}

$userId = $_GET['id'] ?? 0;

if (empty($userId)) {
    echo json_encode(["success" => 0, "message" => "ID étudiant manquant"]);
    exit();
}

$sql = "SELECT u.nom, u.prenom, u.email, c.nom AS classe
        FROM utilisateurs u
        JOIN etudiants e ON e.utilisateur_id = u.id
        JOIN classes c   ON e.classe_id      = c.id
        WHERE u.id = ?";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL"]);
    exit();
}

$stmt->bind_param("i", $userId);

if (!$stmt->execute()) {
    echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération du profil"]);
    exit();
}

$row = $stmt->get_result()->fetch_assoc();

if (!$row) {
    echo json_encode(["success" => 0, "message" => "Étudiant introuvable"]);
} else {
    echo json_encode(["success" => 1, "data" => $row]);
}

$conn->close();
?>