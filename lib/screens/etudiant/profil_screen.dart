import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/etudiant.dart'; 

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Etudiant? _etudiant; // Instance du modèle Etudiant
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

 Future<void> _loadUserProfile() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id') ?? 0;
    
    // 1. Récupération de l'objet déjà construit par ApiService
    final Etudiant? profileData = await ApiService.getProfilEtudiant(id);
    
    if (mounted) {
      setState(() {
        if (profileData != null) {
          _etudiant = profileData; // On assigne directement
        }
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Erreur de décodage : $e"); // TRÈS IMPORTANT : regardez votre console
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _etudiant == null
              ? const Center(child: Text("Impossible de charger les données"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // En-tête avec Avatar
                      _buildHeader(),
                      const SizedBox(height: 30),
                      
                      // Détails du profil
                      Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              _buildInfoTile(Icons.person_outline, "Nom complet", "${_etudiant!.nom} ${_etudiant!.prenom}"),
                              const Divider(height: 30),
                              _buildInfoTile(Icons.alternate_email, "Email", _etudiant!.email),
                              const Divider(height: 30),
                              _buildInfoTile(Icons.school_outlined, "Classe actuelle", _etudiant!.classe),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Bouton de déconnexion
                      _buildLogoutButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.indigo.shade50,
              child: const Icon(Icons.person, size: 60, color: Colors.indigo),
            ),
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.verified, color: Colors.blue, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          "${_etudiant!.prenom} ${_etudiant!.nom}",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Étudiant",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.indigo),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text("DÉCONNEXION"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}