import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/absence.dart';
import '../models/etudiant.dart';
import '../models/seance.dart';

class ApiService {
  
  // --- AUTHENTIFICATION ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Api.login),
        headers: Api.headers,
        body: jsonEncode({"email": email, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": 0, "message": "Erreur de connexion au serveur"};
    }
  }

  // --- ADMINISTRATION : ÉTUDIANTS ---

  static Future<List<Etudiant>> getEtudiants() async {
    try {
      final response = await http.get(Uri.parse(Api.adminEtudiants));
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        List list = data['data'];
        return list.map((item) => Etudiant.fromJson(item)).toList();
      }
    } catch (e) { print("Erreur getEtudiants: $e"); }
    return [];
  }

  static Future<Map<String, dynamic>> ajouterEtudiant(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(Api.adminEtudiants),
      headers: Api.headers,
      body: jsonEncode(data), // Attend: nom, prenom, email, password, classe_id
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> modifierEtudiant(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(Api.adminEtudiants),
      headers: Api.headers,
      body: jsonEncode(data), // Attend: id (etudiant_id), nom, prenom, email, classe_id
    );
    return jsonDecode(response.body);
  }

  // --- ADMINISTRATION : ENSEIGNANTS ---

  static Future<List<dynamic>> getEnseignants() async {
    try {
      final response = await http.get(Uri.parse(Api.adminEnseignants));
      final data = jsonDecode(response.body);
      return data['success'] == 1 ? data['data'] : [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> ajouterEnseignant(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(Api.adminEnseignants),
      headers: Api.headers,
      body: jsonEncode(data), // Attend: nom, prenom, email, password, specialite
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> modifierEnseignant(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(Api.adminEnseignants),
      headers: Api.headers,
      body: jsonEncode(data), // Attend: id (enseignant_id), nom, prenom, email, specialite
    );
    return jsonDecode(response.body);
  }

  // --- ADMINISTRATION : CLASSES ---

  static Future<List<dynamic>> getClasses() async {
    final response = await http.get(Uri.parse(Api.adminClasses));
    final data = jsonDecode(response.body);
    return data['success'] == 1 ? data['data'] : [];
  }

  static Future<Map<String, dynamic>> ajouterClasse(String nom, String niveau) async {
    final response = await http.post(
      Uri.parse(Api.adminClasses),
      headers: Api.headers,
      body: jsonEncode({"nom": nom, "niveau": niveau}),
    );
    return jsonDecode(response.body);
  }

  // --- ADMINISTRATION : SÉANCES (AFFECTATION) ---

  static Future<List<dynamic>> getAllSeances() async {
    final response = await http.get(Uri.parse(Api.adminSeances));
    final data = jsonDecode(response.body);
    return data['success'] == 1 ? data['data'] : [];
  }

  static Future<Map<String, dynamic>> ajouterSeance(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(Api.adminSeances),
      headers: Api.headers,
      body: jsonEncode(data), // Attend: enseignant_id, classe_id, matiere_id, date_seance, heure_debut, heure_fin
    );
    return jsonDecode(response.body);
  }

  // --- ENSEIGNANT ---

  static Future<List<Seance>> getSeancesEnseignant(int userId) async {
    final response = await http.get(Uri.parse(Api.enseignantSeances(userId)));
    final data = jsonDecode(response.body);
    if (data['success'] == 1) {
      List list = data['data'];
      return list.map((item) => Seance.fromJson(item)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> soumettreAppel(int seanceId, List<Map<String, dynamic>> appel) async {
    final response = await http.post(
      Uri.parse(Api.enseignantAppel),
      headers: Api.headers,
      body: jsonEncode({
        "seance_id": seanceId,
        "appel": appel
      }),
    );
    return jsonDecode(response.body);
  }

  // --- ÉTUDIANT ---

  static Future<Etudiant?> getProfilEtudiant(int userId) async {
    try {
      final response = await http.get(Uri.parse(Api.etudiantProfil(userId)));
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        return Etudiant.fromJson(data['data']);
      }
    } catch (e) { print("Erreur API Profil: $e"); }
    return null;
  }

  static Future<List<Absence>> getAbsencesEtudiant(int userId) async {
    final response = await http.get(Uri.parse(Api.etudiantAbsences(userId)));
    final data = jsonDecode(response.body);
    if (data['success'] == 1) {
      List list = data['data'];
      return list.map((item) => Absence.fromJson(item)).toList();
    }
    return [];
  }

  
}