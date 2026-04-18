import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/seance.dart';
import '../../models/etudiant.dart';

class AppelScreen extends StatefulWidget {
  final Seance seance; // Reçoit la séance sélectionnée

  const AppelScreen({super.key, required this.seance});

  @override
  State<AppelScreen> createState() => _AppelScreenState();
}

class _AppelScreenState extends State<AppelScreen> {
  List<Etudiant> _etudiants = [];
  // Map pour stocker l'état de présence : id_etudiant -> true (présent) / false (absent)
  Map<int, bool> _presences = {}; 
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _chargerEtudiants();
  }

  // 1. Charger uniquement les étudiants de la classe concernée
  void _chargerEtudiants() async {
    // Note : s'assurer que widget.seance.classeId existe (voir note en bas)
    final data = await ApiService.getEtudiantsParClasse(widget.seance.classeId);
    
    setState(() {
      _etudiants = data;
      for (var e in data) {
        _presences[e.id] = true; // Par défaut, tout le monde est présent
      }
      _isLoading = false;
    });
  }

  // 2. Valider et envoyer l'appel au serveur
  void _validerLAppel() async {
    setState(() => _isSaving = true);

    // Préparation des données pour POST /enseignant/absences.php
    List<Map<String, dynamic>> listeAppel = [];
    _presences.forEach((id, isPresent) {
      listeAppel.add({
        "etudiant_id": id,
        "statut": isPresent ? 'present' : 'absent'
      });
    });

    final res = await ApiService.soumettreAppel(widget.seance.id, listeAppel);

    setState(() => _isSaving = false);

    if (res['success'] == 1) {
      // 3. Affichage du SnackBar de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Appel enregistré avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Retour à la liste des séances
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur : ${res['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // On remplace le simple Text par une Column
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligne le texte à gauche
          children: [
            Text("Appel : ${widget.seance.matiere}"),
            Text(
              "Classe : ${widget.seance.classe}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ), // Plus petit pour faire "sous-titre"
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _etudiants.isEmpty
              ? const Center(child: Text("Aucun étudiant dans cette classe."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _etudiants.length,
                        itemBuilder: (context, index) {
                          final e = _etudiants[index];
                          return CheckboxListTile(
                            title: Text("${e.nom} ${e.prenom}"),
                            subtitle: Text(_presences[e.id]! ? "Présent" : "Absent"),
                            secondary: const Icon(Icons.person),
                            activeColor: Colors.green,
                            value: _presences[e.id],
                            onChanged: (bool? value) {
                              setState(() {
                                _presences[e.id] = value ?? false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                          onPressed: _isSaving ? null : _validerLAppel,
                          child: _isSaving 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("VALIDER L'APPEL", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}