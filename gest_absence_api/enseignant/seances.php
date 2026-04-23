<?php
require_once '../config/database.php';
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(["success" => 0, "message" => "Méthode non autorisée"]);
    exit();
}

$userId = $_GET['id'] ?? 0;

if (empty($userId)) {
    echo json_encode(["success" => 0, "message" => "ID enseignant manquant"]);
    exit();
}

$sql = "SELECT s.id, s.classe_id, m.nom AS matiere, c.nom AS classe,
               s.date_seance, s.heure_debut, s.heure_fin
        FROM seances s
        JOIN matieres m ON s.matiere_id = m.id
        JOIN classes c  ON s.classe_id  = c.id
        JOIN enseignants e ON s.enseignant_id = e.id
        WHERE e.utilisateur_id = ?";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL"]);
    exit();
}

$stmt->bind_param("i", $userId);

if (!$stmt->execute()) {
    echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des séances"]);
    exit();
}

$result = $stmt->get_result();
$list = [];
while ($row = $result->fetch_assoc()) $list[] = $row;

if (empty($list)) {
    echo json_encode(["success" => 0, "message" => "Aucune séance trouvée pour cet enseignant"]);
} else {
    echo json_encode(["success" => 1, "data" => $list]);
}

$conn->close();
?>