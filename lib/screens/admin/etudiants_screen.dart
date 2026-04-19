import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/etudiant.dart';

class EtudiantsScreen extends StatefulWidget {
  const EtudiantsScreen({super.key});
  @override
  State<EtudiantsScreen> createState() => _EtudiantsScreenState();
}

class _EtudiantsScreenState extends State<EtudiantsScreen> {
  final _nom = TextEditingController(), _prenom = TextEditingController();
  final _email = TextEditingController(), _pass = TextEditingController();
  
  // 1. Nouvelles variables pour la liste déroulante
  int? _selectedClasseId; 
  List<dynamic> _classes = []; 

  @override
  void initState() {
    super.initState();
    _loadClasses(); // 2. On charge les classes dès l'ouverture de l'écran
  }

  Future<void> _loadClasses() async {
    try {
      // On suppose que tu as créé cette méthode dans ApiService qui appelle classes.php
      final classes = await ApiService.getClasses(); 
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des classes");
    }
  }

  void _showForm({Etudiant? etudiant}) {
    if (etudiant != null) {
      _nom.text = etudiant.nom; 
      _prenom.text = etudiant.prenom; 
      _email.text = etudiant.email;
      _selectedClasseId = etudiant.classeId; // On pré-sélectionne la classe de l'étudiant
    } else {
      _nom.clear(); 
      _prenom.clear(); 
      _email.clear(); 
      _pass.clear();
      _selectedClasseId = null; // On vide pour un nouvel ajout
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // 3. StatefulBuilder permet à la liste déroulante de se mettre à jour visuellement
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(etudiant == null ? "Ajouter Étudiant" : "Modifier Étudiant"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nom, decoration: const InputDecoration(labelText: "Nom")),
                  const SizedBox(height: 12), // Ajoute de l'espace pour aérer le formulaire
                  
                  TextField(controller: _prenom, decoration: const InputDecoration(labelText: "Prénom")),
                  const SizedBox(height: 12),
                  
                  TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
                  const SizedBox(height: 12),
                  
                  if (etudiant == null) 
                    TextField(controller: _pass, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
                  if (etudiant == null) 
                    const SizedBox(height: 12),

                  // 4. La Liste Déroulante (Dropdown) remplace le TextField
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: "Sélectionnez une classe",
                      border: OutlineInputBorder(), // Un design plus propre
                    ),
                    value: _selectedClasseId,
                    items: _classes.map((c) {
                      return DropdownMenuItem<int>(
                        // Si ton ApiService.getClasses() retourne des objets Classe, utilise c.id et c.nom
                        // S'il retourne du JSON (Map), utilise c['id'] et c['nom']
                        value: int.parse(c['id'].toString()), 
                        child: Text(c['nom'].toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        _selectedClasseId = val; // Met à jour l'ID sélectionné
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (_selectedClasseId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner une classe")));
                    return; // Stoppe si aucune classe n'est choisie
                  }

                  Map<String, dynamic> data = {
                    "nom": _nom.text, 
                    "prenom": _prenom.text, 
                    "email": _email.text,
                    "classe_id": _selectedClasseId // On envoie le bon ID à PHP
                  };
                  var res;
                  if (etudiant == null) {
                    res = await ApiService.ajouterEtudiant({...data, "password": _pass.text});
                  } else {
                    res = await ApiService.modifierEtudiant({...data, "id": etudiant.id});
                  }
                  if (res['success'] == 1) { 
                    Navigator.pop(ctx); 
                    setState(() {}); 
                  }
                },
                child: const Text("Valider"),
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
      body: FutureBuilder<List<Etudiant>>(
        future: ApiService.getEtudiants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final e = snapshot.data![i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("${e.nom} ${e.prenom}"),
                subtitle: Text("${e.classe} | ${e.email}"),
                trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(etudiant: e)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
    );
  }
}