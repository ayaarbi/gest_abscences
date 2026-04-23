<?php
require_once '../config/database.php';
$conn = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sql = "SELECT e.id, u.nom, u.prenom, u.email, e.specialite
            FROM enseignants e JOIN utilisateurs u ON e.utilisateur_id = u.id";
    $result = $conn->query($sql);

    if (!$result) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la récupération des enseignants"]);
    } else {
        $list = [];
        while ($row = $result->fetch_assoc()) $list[] = $row;
        echo json_encode(["success" => 1, "data" => $list]);
    }

} elseif ($method === 'POST') {
    $d = json_decode(file_get_contents("php://input"), true);

    if (empty($d['nom']) || empty($d['prenom']) || empty($d['email']) || empty($d['password'])) {
        echo json_encode(["success" => 0, "message" => "Tous les champs obligatoires sont requis"]);
        exit();
    }

    $stmt = $conn->prepare("INSERT INTO utilisateurs (nom,prenom,email,password,role) VALUES (?,?,?,?,'enseignant')");

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
    $stmt2  = $conn->prepare("INSERT INTO enseignants (utilisateur_id, specialite) VALUES (?,?)");

    if (!$stmt2) {
        echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL (enseignants)"]);
        exit();
    }

    $stmt2->bind_param("is", $userId, $d['specialite']);

    if (!$stmt2->execute()) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de l'ajout de l'enseignant"]);
    } else {
        echo json_encode(["success" => 1, "message" => "Enseignant ajouté avec succès"]);
    }

} elseif ($method === 'PUT') {
    $d = json_decode(file_get_contents("php://input"), true);

    if (empty($d['id']) || empty($d['nom']) || empty($d['prenom']) || empty($d['email'])) {
        echo json_encode(["success" => 0, "message" => "Champs manquants pour la modification"]);
        exit();
    }

    $stmt = $conn->prepare("UPDATE utilisateurs SET nom=?, prenom=?, email=? WHERE id=(SELECT utilisateur_id FROM enseignants WHERE id=?)");

    if (!$stmt) {
        echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL"]);
        exit();
    }

    $stmt->bind_param("sssi", $d['nom'], $d['prenom'], $d['email'], $d['id']);

    if (!$stmt->execute()) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la modification de l'utilisateur"]);
        exit();
    }

    $stmt2 = $conn->prepare("UPDATE enseignants SET specialite=? WHERE id=?");

    if (!$stmt2) {
        echo json_encode(["success" => 0, "message" => "Erreur de préparation SQL (spécialité)"]);
        exit();
    }

    $stmt2->bind_param("si", $d['specialite'], $d['id']);

    if (!$stmt2->execute()) {
        echo json_encode(["success" => 0, "message" => "Erreur lors de la modification de la spécialité"]);
    } else {
        echo json_encode(["success" => 1, "message" => "Enseignant modifié avec succès"]);
    }

} else {
    echo json_encode(["success" => 0, "message" => "Méthode non autorisée"]);
}

$conn->close();
?>