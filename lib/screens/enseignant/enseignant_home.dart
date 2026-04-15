import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mes_seances_screen.dart';

class EnseignantHome extends StatefulWidget {
  const EnseignantHome({super.key});

  @override
  State<EnseignantHome> createState() => _EnseignantHomeState();
}

class _EnseignantHomeState extends State<EnseignantHome> {
  String _nom = "";

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  // Récupère le nom stocké lors du login pour personnaliser l'accueil
  void _loadInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nom = prefs.getString('nom') ?? "Enseignant";
    });
  }

  // Fonction pour vider les préférences et retourner au login
  void _deconnexion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Efface l'ID, le nom, le rôle, etc.
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour, $_nom"),
        centerTitle: false, // Aligné à gauche pour un look moderne
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            tooltip: "Se déconnecter",
            icon: const Icon(Icons.logout),
            onPressed: () => _deconnexion(context),
          )
        ],
      ),
      // Affiche le composant MesSeancesScreen que nous avons typé avec le modèle Seance
      body: const MesSeancesScreen(), 
    );
  }
}