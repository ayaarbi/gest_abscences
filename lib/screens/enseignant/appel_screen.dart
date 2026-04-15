import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/seance.dart';   // Import du modèle Seance
import '../../models/etudiant.dart'; // Import du modèle Etudiant

class AppelScreen extends StatefulWidget {
  // Le constructeur accepte maintenant l'objet Seance typé
  final Seance seance; 
  const AppelScreen({super.key, required this.seance});

  @override
  State<AppelScreen> createState() => _AppelScreenState();
}

class _AppelScreenState extends State<AppelScreen> {
  // Utilisation du modèle Etudiant pour la liste
  List<Etudiant> _etudiants = [];
  Map<int, String> _presences = {}; 
  bool _saving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerEtudiants();
  }

  void _chargerEtudiants() async {
    // ApiService.getEtudiants() retourne maintenant une List<Etudiant>
    final data = await ApiService.getEtudiants(); 
    setState(() {
      _etudiants = data;
      for (var e in data) {
        // e.id est déjà un int dans le modèle Etudiant
        _presences[e.id] = 'present'; 
      }
      _isLoading = false;
    });
  }

  void _valider() async {
    setState(() => _saving = true);
    List<Map<String, dynamic>> listeAppel = [];
    
    _presences.forEach((id, statut) {
      listeAppel.add({"etudiant_id": id, "statut": statut});
    });

    // widget.seance.id est utilisé directement (c'est un int)
    final res = await ApiService.soumettreAppel(widget.seance.id, listeAppel);
    
    if (res['success'] == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appel enregistré avec succès !"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${res['message']}"), backgroundColor: Colors.red),
      );
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appel : ${widget.seance.matiere}"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.indigo.withOpacity(0.05),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.indigo),
                    const SizedBox(width: 10),
                    Text(
                      "Liste des étudiants (${_etudiants.length})",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _etudiants.length,
                  itemBuilder: (context, index) {
                    final e = _etudiants[index];
                    final isPresent = _presences[e.id] == 'present';
                    
                    return ListTile(
                      title: Text("${e.nom} ${e.prenom}", style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(e.classe),
                      trailing: ChoiceChip(
                        label: Text(isPresent ? "Présent" : "Absent"),
                        selected: isPresent,
                        selectedColor: Colors.green.shade100,
                        checkmarkColor: Colors.green,
                        onSelected: (val) {
                          setState(() => _presences[e.id] = val ? 'present' : 'absent');
                        },
                      ),
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
                    onPressed: _saving ? null : _valider,
                    child: _saving 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("VALIDER L'APPEL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}