class Seance {
  final int id;
  final String matiere;
  final String classe;
  final String dateSeance;
  final String heureDebut;
  final String? heureFin;

  Seance({
    required this.id,
    required this.matiere,
    required this.classe,
    required this.dateSeance,
    required this.heureDebut,
    this.heureFin,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: int.parse(json['id'].toString()),
      matiere: json['matiere'] ?? '',
      classe: json['classe'] ?? '',
      dateSeance: json['date_seance'] ?? '',
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'],
    );
  }
}