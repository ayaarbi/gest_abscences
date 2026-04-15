class Etudiant {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String classe;

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.classe,
  });

  // lib/models/etudiant.dart
factory Etudiant.fromJson(Map<String, dynamic> json) {
  return Etudiant(
    // Utilisation de .toString() avant le parse pour éviter les erreurs de type
    id: int.tryParse(json['id'].toString()) ?? 0,
    nom: json['nom']?.toString() ?? '',
    prenom: json['prenom']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    // Si votre PHP n'envoie pas 'classe', mettez une valeur par défaut
    classe: json['classe']?.toString() ?? json['nom_classe']?.toString() ?? 'N/A',
  );
}
}