import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});
  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  final _date = TextEditingController(), _hD = TextEditingController(), _hF = TextEditingController();
  final _profId = TextEditingController(), _classeId = TextEditingController(), _matiereId = TextEditingController();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Affecter une Séance"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _profId, decoration: const InputDecoration(labelText: "ID Enseignant"), keyboardType: TextInputType.number),
              TextField(controller: _classeId, decoration: const InputDecoration(labelText: "ID Classe"), keyboardType: TextInputType.number),
              TextField(controller: _matiereId, decoration: const InputDecoration(labelText: "ID Matière"), keyboardType: TextInputType.number),
              TextField(controller: _date, decoration: const InputDecoration(labelText: "Date (AAAA-MM-JJ)")),
              TextField(controller: _hD, decoration: const InputDecoration(labelText: "Heure Début (HH:MM)")),
              TextField(controller: _hF, decoration: const InputDecoration(labelText: "Heure Fin (HH:MM)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              var res = await ApiService.ajouterSeance({
                "enseignant_id": _profId.text, "classe_id": _classeId.text,
                "matiere_id": _matiereId.text, "date_seance": _date.text,
                "heure_debut": _hD.text, "heure_fin": _hF.text
              });
              if (res['success'] == 1) { Navigator.pop(ctx); setState(() {}); }
            },
            child: const Text("Affecter"),
          )
        ],
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