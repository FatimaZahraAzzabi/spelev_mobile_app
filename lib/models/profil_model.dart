class ProfilModel {
  final int? id;
  final String? prenom;
  final String? nom;
  final String? email;
  final String? telephone;
  final String? entreprise;
  final String? adresse;

  const ProfilModel({this.id, this.prenom, this.nom, this.email, this.telephone, this.entreprise, this.adresse});

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id: json['id'],
      prenom: json['prenom'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      entreprise: json['entreprise'] ?? json['nomEntreprise'] ?? json['societe'],
      adresse: json['adresse'],
    );
  }

  String get nomComplet => '${prenom ?? ''} ${nom ?? ''}'.trim();
}