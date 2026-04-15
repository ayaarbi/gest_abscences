// lib/config/api_config.dart

const String baseUrl = 'http://localhost/gest_absence_api';

class Api {
  static const Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // -- Auth --
  static const String login = '$baseUrl/auth/login.php';

  // -- Admin --
  static const String adminEtudiants   = '$baseUrl/admin/etudiants.php';
  static const String adminEnseignants = '$baseUrl/admin/enseignants.php';
  static const String adminClasses     = '$baseUrl/admin/classes.php';
  static const String adminSeances     = '$baseUrl/admin/seances.php';

  // -- Enseignant --
  static String enseignantSeances(int userId) => '$baseUrl/enseignant/seances.php?id=$userId';
  static const String enseignantAppel = '$baseUrl/enseignant/absences.php';

  // -- Étudiant --
  static String etudiantProfil(int userId)   => '$baseUrl/etudiant/profil.php?id=$userId';
  static String etudiantAbsences(int userId) => '$baseUrl/etudiant/absences.php?id=$userId';

  // Pour l'appel (récupérer les élèves d'une classe précise)
  static String etudiantsParClasse(int classeId) => '$baseUrl/admin/etudiants.php?classe_id=$classeId';
}