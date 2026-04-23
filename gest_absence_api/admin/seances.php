<?php
require_once '../config/database.php';
$conn = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sql = "SELECT s.id, s.classe_id, m.nom AS matiere, c.nom AS classe,
                   CONCAT(u.nom,' ',u.prenom) AS enseignant,
                   s.date_seance, s.heure_debut, s.heure_fin
            FROM seances s
            JOIN matieres m  ON s.matiere_id   = m.id
            JOIN classes c   ON s.classe_id    = c.id
            JOIN enseignants e ON s.enseignant_id = e.id
            JOIN utilisateurs u ON e.utilisateur_id = u.id";
    $result = $conn->query($sql);

    if (!$result) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des séances"]);
    } else {
        $list = [];
        while ($row = $result->fetch_assoc()) $list[] = $row;
        echo json_encode(["success" => 1, "data" => $list]);
    }

} elseif ($method === 'POST') {
    $d = json_decode(file_get_contents("php://input"), true);

    if (empty($d['enseignant_id']) || empty($d['classe_id']) || empty($d['matiere_id']) || empty($d['date_seance']) || empty($d['heure_debut']) || empty($d['heure_fin'])) {
        echo json_encode(["success" => 0, "message" => "Tous les champs sont requis pour créer une séance"]);
        exit();
    }

    $stmt = $conn->prepare("INSERT INTO seances (enseignant_id,classe_id,matiere_id,date_seance,heure_debut,heure_fin) VALUES (?,?,?,?,?,?)");

    if (!$stmt) {
        echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL"]);
        exit();
    }

    $stmt->bind_param("iiisss", $d['enseignant_id'], $d['classe_id'], $d['matiere_id'], $d['date_seance'], $d['heure_debut'], $d['heure_fin']);

    if (!$stmt->execute()) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de l'ajout de la séance"]);
    } else {
        echo json_encode(["success" => 1, "message" => "Séance ajoutée avec succès"]);
    }

} else {
    echo json_encode(["success" => 0, "message" => "Méthode non autorisée"]);
}

$conn->close();
?>