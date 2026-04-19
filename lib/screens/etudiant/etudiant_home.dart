import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profil_screen.dart';   
import 'absences_screen.dart'; 

class EtudiantHome extends StatelessWidget {
  const EtudiantHome({super.key});

  // Fonction pour vider la session et revenir au login
  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mon Espace Étudiant"),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          // Bouton de déconnexion rapide dans l'AppBar
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.person_outline), text: "PROFIL"),
              Tab(icon: Icon(Icons.history_outlined), text: "ABSENCES"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProfilScreen(),
            AbsencesScreen(),
          ],
        ),
      ),
    );
  }
}