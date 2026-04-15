// lib/screens/admin/classes_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});
  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _nomCtrl = TextEditingController();
  final _niveauCtrl = TextEditingController();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une Classe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nomCtrl, decoration: const InputDecoration(labelText: "Nom (ex: CI2-A)")),
            TextField(controller: _niveauCtrl, decoration: const InputDecoration(labelText: "Niveau")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final res = await ApiService.ajouterClasse(_nomCtrl.text, _niveauCtrl.text);
              if (res['success'] == 1) {
                _nomCtrl.clear(); _niveauCtrl.clear();
                Navigator.pop(context);
                setState(() {}); // Rafraîchir la liste
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getClasses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final c = snapshot.data![index];
              return ListTile(
                leading: const Icon(Icons.class_outlined),
                title: Text(c['nom']),
                subtitle: Text(c['niveau'] ?? ""),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}