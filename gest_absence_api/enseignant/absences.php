<?php
require_once '../config/database.php';
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => 0, "message" => "Méthode non autorisée"]);
    exit();
}

$d = json_decode(file_get_contents("php://input"), true);

//Flutter envoie 
/*

{
  "seance_id": 3,
  "appel": [
    {"etudiant_id": 1, "statut": "present"},
    {"etudiant_id": 2, "statut": "absent"},
    {"etudiant_id": 3, "statut": "present"}
  ]
}

*/

if (empty($d['seance_id']) || empty($d['appel']) || !is_array($d['appel'])) {
    echo json_encode(["success" => 0, "message" => "Données de l'appel manquantes ou invalides"]);
    exit();
}

$seanceId = $d['seance_id'];
$erreurs  = 0;

foreach ($d['appel'] as $item) {
    if (empty($item['etudiant_id']) || empty($item['statut'])) {
        $erreurs++;
        continue;
    }

    $stmt = $conn->prepare(
        "INSERT INTO absences (seance_id, etudiant_id, statut)
         VALUES (?,?,?)
         ON DUPLICATE KEY UPDATE statut=VALUES(statut)" //Cela signifie qu'il ne peut pas exister deux lignes avec le même seance_id + etudiant_id
    );

    if (!$stmt) {
        $erreurs++;
        continue;  // pour éviter le blocage de la boucle
    }

    $stmt->bind_param("iis", $seanceId, $item['etudiant_id'], $item['statut']);

    if (!$stmt->execute()) {
        $erreurs++;
    }
}

if ($erreurs === 0) {
    echo json_encode(["success" => 1, "message" => "Appel enregistré avec succès"]);
} else {
    echo json_encode(["success" => 0, "message" => "Appel partiellement enregistré, $erreurs erreur(s) détectée(s)"]);
}

$conn->close();
?>