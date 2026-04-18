import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});
  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  // On garde les contrôleurs uniquement pour les heures de début et de fin
  final _hD = TextEditingController();
  final _hF = TextEditingController();

  // Nouvelles variables pour stocker les sélections
  int? _selectedProfId;
  int? _selectedClasseId;
  int? _selectedMatiereId;
  DateTime? _selectedDate;

  // Listes pour stocker les données récupérées de la base de données
  List<dynamic> _enseignants = [];
  List<dynamic> _classes = [];
  List<dynamic> _matieres = []; // Nécessite une méthode getMatieres dans ton ApiService !

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charge toutes les listes nécessaires pour les Dropdowns
  Future<void> _loadData() async {
    try {
      final enseignants = await ApiService.getEnseignants();
      final classes = await ApiService.getClasses();
      // Attention : assure-toi d'avoir créé getMatieres() dans ApiService
      final matieres = await ApiService.getMatieres(); 

      setState(() {
        _enseignants = enseignants;
        _classes = classes;
        _matieres = matieres;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des listes");
    }
  }

  void _showAddDialog() {
    // Réinitialise les champs à chaque ouverture
    _selectedProfId = null;
    _selectedClasseId = null;
    _selectedMatiereId = null;
    _selectedDate = null;
    _hD.clear();
    _hF.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // StatefulBuilder est obligatoire pour rafraîchir le calendrier et les listes
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Affecter une Séance"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- 1. Dropdown Enseignant ---
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Enseignant", border: OutlineInputBorder()),
                    value: _selectedProfId,
                    items: _enseignants.map((e) => DropdownMenuItem<int>(
                      value: int.parse(e['id'].toString()),
                      child: Text("${e['nom']} ${e['prenom']}"),
                    )).toList(),
                    onChanged: (val) => setStateDialog(() => _selectedProfId = val),
                  ),
                  const SizedBox(height: 12),

                  // --- 2. Dropdown Classe ---
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Classe", border: OutlineInputBorder()),
                    value: _selectedClasseId,
                    items: _classes.map((c) => DropdownMenuItem<int>(
                      value: int.parse(c['id'].toString()),
                      child: Text(c['nom'].toString()),
                    )).toList(),
                    onChanged: (val) => setStateDialog(() => _selectedClasseId = val),
                  ),
                  const SizedBox(height: 12),

                  // --- 3. Dropdown Matière ---
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Matière", border: OutlineInputBorder()),
                    value: _selectedMatiereId,
                    items: _matieres.map((m) => DropdownMenuItem<int>(
                      value: int.parse(m['id'].toString()),
                      child: Text(m['nom'].toString()),
                    )).toList(),
                    onChanged: (val) => setStateDialog(() => _selectedMatiereId = val),
                  ),
                  const SizedBox(height: 12),

                  // --- 4. Sélecteur de Date (Calendrier) ---
                  InkWell(
                    onTap: () async {
                      // Ouvre le calendrier natif de Flutter
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023), // L'année minimum
                        lastDate: DateTime(2030),  // L'année maximum
                      );
                      if (pickedDate != null) {
                        setStateDialog(() => _selectedDate = pickedDate);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Date de la séance", 
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      // Formate la date en YYYY-MM-DD si elle est choisie
                      child: Text(_selectedDate == null 
                        ? "Appuyez pour choisir" 
                        : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- 5. Champs Heure --- (Mis côte à côte pour gagner de la place)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hD, 
                          decoration: const InputDecoration(labelText: "Début (HH:MM)", border: OutlineInputBorder())
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _hF, 
                          decoration: const InputDecoration(labelText: "Fin (HH:MM)", border: OutlineInputBorder())
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              
              ElevatedButton(
                onPressed: () async {
                  // Vérification des champs
                  if (_selectedProfId == null || _selectedClasseId == null || _selectedMatiereId == null || _selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs !")));
                    return;
                  }

                  // Formatage de la date pour la base de données (YYYY-MM-DD)
                  String dateSQL = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                  var res = await ApiService.ajouterSeance({
                    "enseignant_id": _selectedProfId,
                    "classe_id": _selectedClasseId,
                    "matiere_id": _selectedMatiereId,
                    "date_seance": dateSQL,
                    "heure_debut": _hD.text,
                    "heure_fin": _hF.text
                  });
                  
                  if (res['success'] == 1) { 
                    Navigator.pop(ctx); 
                    setState(() {}); 
                  }
                },
                child: const Text("Affecter"),
              ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getAllSeances(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final s = snapshot.data![i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(s['matiere']),
                  subtitle: Text("Classe: ${s['classe']} | Prof: ${s['enseignant']}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s['date_seance'], style: const TextStyle(fontSize: 12)),
                      Text("${s['heure_debut']} - ${s['heure_fin']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add_task)),
    );
  }
}