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

$sql = "SELECT m.nom AS matiere, s.date_seance, s.heure_debut, a.statut
        FROM absences a
        JOIN seances s    ON a.seance_id   = s.id
        JOIN matieres m   ON s.matiere_id  = m.id
        JOIN etudiants e  ON a.etudiant_id = e.id
        WHERE e.utilisateur_id = ?
        ORDER BY s.date_seance DESC";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL"]);
    exit();
}

$stmt->bind_param("i", $userId);

if (!$stmt->execute()) {
    echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des absences"]);
    exit();
}

$result = $stmt->get_result();
$list   = [];
while ($row = $result->fetch_assoc()) $list[] = $row;

if (empty($list)) {
    echo json_encode(["success" => 0, "message" => "Aucune absence enregistrée"]);
} else {
    echo json_encode(["success" => 1, "data" => $list]);
}

$conn->close();
?>