<?php
require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => 0, "message" => "Methode non autorisee"]);
    exit();
}

// Récupère le JSON envoyé par Flutter et le transforme en tableau php
$data = json_decode(file_get_contents("php://input"), true);
$email    = $data['email']    ?? ''; // ?? valeur par defaut
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["success" => 0, "message" => "Email et mot de passe requis"]);
    exit();
}

$conn = getConnection();
$stmt = $conn->prepare("SELECT id, nom, prenom, role FROM utilisateurs WHERE email=? AND password=?");
$stmt->bind_param("ss", $email, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc(); // transfome la ligne mysql en tableau php
    echo json_encode(["success" => 1, "data" => $user]);
} else {
    echo json_encode(["success" => 0, "message" => "Email ou mot de passe incorrect"]);
}

$stmt->close();
$conn->close();
?>