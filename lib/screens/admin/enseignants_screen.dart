import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EnseignantsScreen extends StatefulWidget {
  const EnseignantsScreen({super.key});
  @override
  State<EnseignantsScreen> createState() => _EnseignantsScreenState();
}

class _EnseignantsScreenState extends State<EnseignantsScreen> {
  final _nom = TextEditingController(), _prenom = TextEditingController();
  final _email = TextEditingController(), _spec = TextEditingController();
  final _pass = TextEditingController();

  void _showForm({Map<String, dynamic>? prof}) {
    if (prof != null) {
      _nom.text = prof['nom']; _prenom.text = prof['prenom'];
      _email.text = prof['email']; _spec.text = prof['specialite'];
    } else {
      _nom.clear(); _prenom.clear(); _email.clear(); _spec.clear(); _pass.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(prof == null ? "Ajouter Enseignant" : "Modifier Enseignant"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nom, decoration: const InputDecoration(labelText: "Nom")),
              TextField(controller: _prenom, decoration: const InputDecoration(labelText: "Prénom")),
              TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
              if (prof == null) TextField(controller: _pass, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
              TextField(controller: _spec, decoration: const InputDecoration(labelText: "Spécialité")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> data = {"nom": _nom.text, "prenom": _prenom.text, "email": _email.text, "specialite": _spec.text};
              var res = prof == null 
                ? await ApiService.ajouterEnseignant({...data, "password": _pass.text})
                : await ApiService.modifierEnseignant({...data, "id": prof['id']});
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
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getEnseignants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final p = snapshot.data![i];
              return ListTile(
                leading: const Icon(Icons.school, color: Colors.indigo),
                title: Text("${p['nom']} ${p['prenom']}"),
                subtitle: Text(p['specialite']),
                trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(prof: p)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.person_add)),
    );
  }
}