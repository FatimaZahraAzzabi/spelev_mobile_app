class UtilisateurModel {
  final int id;
  final String email;
  final String telephone;
  final String motDePasse; // Uniquement pour la création (jamais renvoyé par le backend)
  final String nom;
  final String prenom;
  final String nomEntreprise; // Présent dans le parent Utilisateur
  final bool actif;
  final String type; // "ADMINISTRATEUR", "TECHNICIEN", "CLIENT", "RESPONSABLE_MAINTENANCE"
  
  // Champs spécifiques aux enfants
  final String? specialite;    // Technicien uniquement
  final bool? disponible;      // Technicien uniquement
  final String? adresse;       // Client uniquement

  UtilisateurModel({
    required this.id,
    required this.email,
    required this.telephone,
    this.motDePasse = '',
    required this.nom,
    required this.prenom,
    this.nomEntreprise = '',
    this.actif = true,
    required this.type,
    this.specialite,
    this.disponible,
    this.adresse,
  });

  factory UtilisateurModel.fromJson(Map<String, dynamic> json) {
    return UtilisateurModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      nomEntreprise: json['nomEntreprise'] as String? ?? '',
      actif: json['actif'] as bool? ?? true,
      type: json['type'] as String? ?? 'CLIENT',
      specialite: json['specialite'] as String?,
      disponible: json['disponible'] as bool?,
      adresse: json['adresse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telephone': telephone,
      'nom': nom,
      'prenom': prenom,
      'nomEntreprise': nomEntreprise,
      'actif': actif,
      'type': type,
      'specialite': specialite,
      'disponible': disponible,
      'adresse': adresse,
    };
  }
}

// DTO pour la création d'un utilisateur
class UtilisateurCreateDTO {
  final String email;
  final String telephone;
  final String motDePasse;
  final String nom;
  final String prenom;
  final String type; // "ADMINISTRATEUR", "TECHNICIEN", "CLIENT", "RESPONSABLE_MAINTENANCE"
  final String? nomEntreprise;
  final String? specialite;
  final String? adresse;

  UtilisateurCreateDTO({
    required this.email,
    required this.telephone,
    required this.motDePasse,
    required this.nom,
    required this.prenom,
    required this.type,
    this.nomEntreprise,
    this.specialite,
    this.adresse,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'telephone': telephone,
      'motDePasse': motDePasse,
      'nom': nom,
      'prenom': prenom,
      'type': type,
      'nomEntreprise': nomEntreprise,
      'specialite': specialite,
      'adresse': adresse,
    };
  }
}

// DTO pour la modification
class UtilisateurUpdateDTO {
  final String email;
  final String telephone;
  final String nom;
  final String prenom;
  final String type;
  final bool actif;
  final String? nomEntreprise;
  final String? specialite;
  final String? adresse;

  UtilisateurUpdateDTO({
    required this.email,
    required this.telephone,
    required this.nom,
    required this.prenom,
    required this.type,
    required this.actif,
    this.nomEntreprise,
    this.specialite,
    this.adresse,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'telephone': telephone,
      'nom': nom,
      'prenom': prenom,
      'type': type,
      'actif': actif,
      'nomEntreprise': nomEntreprise,
      'specialite': specialite,
      'adresse': adresse,
    };
  }
}