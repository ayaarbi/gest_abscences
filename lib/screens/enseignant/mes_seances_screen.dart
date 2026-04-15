import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/seance.dart'; // Import du modèle
import 'appel_screen.dart';

class MesSeancesScreen extends StatefulWidget {
  const MesSeancesScreen({super.key});

  @override
  State<MesSeancesScreen> createState() => _MesSeancesScreenState();
}

class _MesSeancesScreenState extends State<MesSeancesScreen> {
  // Modification du type de la liste : on utilise le modèle Seance
  List<Seance> _seances = []; 
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerSeances();
  }

  Future<void> _chargerSeances() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id') ?? 0;
    
    // ApiService retourne maintenant List<Seance>
    final data = await ApiService.getSeancesEnseignant(id);
    
    setState(() {
      _seances = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    if (_seances.isEmpty) {
      return const Center(child: Text("Aucune séance trouvée."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _seances.length,
      itemBuilder: (context, index) {
        // On récupère l'objet Seance
        final s = _seances[index]; 
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.calendar_today, color: Colors.indigo)),
            // Utilisation des propriétés de l'objet (s.matiere au lieu de s['matiere'])
            title: Text(s.matiere, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Classe : ${s.classe}\n${s.dateSeance} à ${s.heureDebut}"),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AppelScreen(seance: s)),
            ),
          ),
        );
      },
    );
  }
}