import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/absence.dart'; // Import du modèle Absence

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  // Utilisation d'une liste typée Absence
  List<Absence> _absences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerAbsences();
  }

  Future<void> _chargerAbsences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;
      
      // ApiService retourne désormais List<Absence>
      final data = await ApiService.getAbsencesEtudiant(userId);
      
      setState(() {
        _absences = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de synchronisation des absences")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_absences.isEmpty) {
      return RefreshIndicator(
        onRefresh: _chargerAbsences,
        child: ListView( // Utilisation d'un ListView pour permettre le pull-to-refresh même si vide
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Column(
                children: [
                  Icon(Icons.verified_user_outlined, size: 80, color: Colors.green.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    "Félicitations !\nAucune absence enregistrée.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerAbsences,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _absences.length,
        itemBuilder: (context, index) {
          final Absence a = _absences[index];
          
          // Logique de couleur basée sur le statut de l'objet
          final Color statusColor = a.statut.toLowerCase() == 'absent' 
              ? Colors.red 
              : Colors.orange;

          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_today_outlined, color: statusColor),
              ),
              title: Text(
                a.matiere,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(a.dateSeance),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("Début : ${a.heureDebut}"),
                    ],
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a.statut.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 10
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}