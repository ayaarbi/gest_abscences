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
  String? _selectedClasseId;

  void _showForm({Etudiant? etudiant}) {
    if (etudiant != null) {
      _nom.text = etudiant.nom; _prenom.text = etudiant.prenom; _email.text = etudiant.email;
    } else {
      _nom.clear(); _prenom.clear(); _email.clear(); _pass.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(etudiant == null ? "Ajouter Étudiant" : "Modifier Étudiant"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nom, decoration: const InputDecoration(labelText: "Nom")),
              TextField(controller: _prenom, decoration: const InputDecoration(labelText: "Prénom")),
              TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
              if (etudiant == null) TextField(controller: _pass, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
              TextField(
                decoration: const InputDecoration(labelText: "ID Classe"),
                keyboardType: TextInputType.number,
                onChanged: (v) => _selectedClasseId = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> data = {
                "nom": _nom.text, "prenom": _prenom.text, "email": _email.text,
                "classe_id": _selectedClasseId
              };
              var res;
              if (etudiant == null) {
                res = await ApiService.ajouterEtudiant({...data, "password": _pass.text});
              } else {
                res = await ApiService.modifierEtudiant({...data, "id": etudiant.id});
              }
              if (res['success'] == 1) { Navigator.pop(ctx); setState(() {}); }
            },
            child: const Text("Valider"),
          )
        ],
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