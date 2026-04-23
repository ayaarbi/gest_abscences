<?php
require_once '../config/database.php';
$conn = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

// GET — liste tous les étudiants
/*
if ($method === 'GET') {
    $sql = "SELECT e.id, u.nom, u.prenom, u.email, c.nom AS classe , e.classe_id
            FROM etudiants e
            JOIN utilisateurs u ON e.utilisateur_id = u.id
            JOIN classes c ON e.classe_id = c.id";
    $result = $conn->query($sql);

    if (!$result) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des étudiants"]);
    } else {
        $list = [];
        while ($row = $result->fetch_assoc()) $list[] = $row;
        echo json_encode(["success" => 1, "data" => $list]);
    }
*/
// --- Dans etudiants.php ---
if ($method === 'GET') {
    // On regarde si un ID de classe est passé dans l'URL
    $classeId = $_GET['classe_id'] ?? null;

    // J'ai remis e.classe_id ici, c'est obligatoire pour ton application Flutter !
    $sql = "SELECT e.id, u.nom, u.prenom, u.email, c.nom AS classe, e.classe_id
            FROM etudiants e
            JOIN utilisateurs u ON e.utilisateur_id = u.id
            JOIN classes c ON e.classe_id = c.id";
    
    // CORRECTION ICI : On vérifie explicitement que la valeur n'est pas null et pas vide
    // Ainsi, même si Flutter envoie "0", la condition s'active !
    if ($classeId !== null && $classeId !== '') {
        $sql .= " WHERE e.classe_id = " . intval($classeId);
    }

    $result = $conn->query($sql);

    if (!$result) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des étudiants"]);
    } else {
        $list = [];
        while ($row = $result->fetch_assoc()) {
            $list[] = $row;
        }
        echo json_encode(["success" => 1, "data" => $list]);
    }

// POST — ajouter un étudiant
// on doit insérer dans les 2 tables 'utilisateur' et 'etudiants'
} elseif ($method === 'POST') {
    $d = json_decode(file_get_contents("php://input"), true);

    if (empty($d['nom']) || empty($d['prenom']) || empty($d['email']) || empty($d['password']) || empty($d['classe_id'])) {
        echo json_encode(["success" => 0, "message" => "Tous les champs sont requis"]);
        exit();
    }

    $stmt = $conn->prepare("INSERT INTO utilisateurs (nom,prenom,email,password,role) VALUES (?,?,?,?,'etudiant')");

    if (!$stmt) {
        echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL"]);
        exit();
    }

    $stmt->bind_param("ssss", $d['nom'], $d['prenom'], $d['email'], $d['password']);

    if (!$stmt->execute()) {
        echo json_encode(["success" => 0, "message" => "Email déjà utilisé ou erreur d'insertion"]);
        exit();
    }

    $userId = $conn->insert_id;

    $stmt2 = $conn->prepare("INSERT INTO etudiants (utilisateur_id, classe_id) VALUES (?,?)");

    if (!$stmt2) {
        echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL (etudiants)"]);
        exit();
    }

    $stmt2->bind_param("ii", $userId, $d['classe_id']);

    if (!$stmt2->execute()) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de l'affectation à la classe"]);
    } else {
        echo json_encode(["success" => 1, "message" => "Étudiant ajouté avec succès"]);
    }


// PUT — modifier un étudiant
} elseif ($method === 'PUT') {
    $d = json_decode(file_get_contents("php://input"), true);

    if (empty($d['id']) ||empty($d['nom']) ||empty($d['prenom']) ||empty($d['email']) ||empty($d['classe_id'])) {
        echo json_encode(["success" => 0, "message" => "Champs manquants pour la modification"]);
        exit();
    }

    $stmt1 = $conn->prepare("UPDATE utilisateurs SET nom=?, prenom=?, email=? WHERE id=(SELECT utilisateur_id FROM etudiants WHERE id=?)");
    if (!$stmt1) {
        echo json_encode(["success" => 0, "message" => "Erreur SQL (utilisateurs)"]);
        exit();
    }

    $stmt1->bind_param("sssi", $d['nom'], $d['prenom'], $d['email'], $d['id']);
    $stmt1->execute();

    $stmt2 = $conn->prepare("UPDATE etudiants SET classe_id=? WHERE id=?");

    if (!$stmt2) {
        echo json_encode(["success" => 0, "message" => "Erreur SQL (classe)"]);
        exit();
    }

    $stmt2->bind_param("ii", $d['classe_id'], $d['id']);
    $stmt2->execute();

    echo json_encode(["success" => 1, "message" => "Étudiant modifié avec succès"]);
}

$conn->close();
?>