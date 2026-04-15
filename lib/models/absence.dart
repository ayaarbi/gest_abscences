class Absence {
  final String matiere;
  final String dateSeance;
  final String heureDebut;
  final String statut;

  Absence({
    required this.matiere,
    required this.dateSeance,
    required this.heureDebut,
    required this.statut,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      matiere: json['matiere'] ?? '',
      dateSeance: json['date_seance'] ?? '',
      heureDebut: json['heure_debut'] ?? '',
      statut: json['statut'] ?? '',
    );
  }
}