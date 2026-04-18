class Seance {
  final int id;
  final int classeId;
  final String matiere;
  final String classe;
  final String dateSeance;
  final String heureDebut;
  final String? heureFin;

  Seance({
    required this.id,
    required this.classeId,
    required this.matiere,
    required this.classe,
    required this.dateSeance,
    required this.heureDebut,
    this.heureFin,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      // S'il n'y a pas d'ID, on met 0 par défaut au lieu de crasher
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      
      // Même chose pour le classe_id
      classeId: int.tryParse(json['classe_id']?.toString() ?? '0') ?? 0,
      
      matiere: json['matiere']?.toString() ?? '',
      classe: json['classe']?.toString() ?? '',
      dateSeance: json['date_seance']?.toString() ?? '',
      heureDebut: json['heure_debut']?.toString() ?? '',
      heureFin: json['heure_fin']?.toString(),
    );
  }
}