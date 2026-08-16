class DemandeMaintenanceModel {
  final int id;
  final String typeDemande; 
  final String priorite;
  final String statut; 
  final String description;
  final String? dateSouhaitee;
  final String? motifRejet;
  final int ascenseurId;
  final String ascenseurNom;
  final int clientId;
  final String clientNom;
  final String? createdAt;
  final List<dynamic> photos;

  DemandeMaintenanceModel({
    required this.id,
    required this.typeDemande,
    required this.priorite,
    required this.statut,
    required this.description,
    this.dateSouhaitee,
    this.motifRejet,
    required this.ascenseurId,
    required this.ascenseurNom,
    required this.clientId,
    required this.clientNom,
    this.createdAt,
    this.photos = const [],
  });

  factory DemandeMaintenanceModel.fromJson(Map<String, dynamic> json) {
    return DemandeMaintenanceModel(
      id: json['id'],
      typeDemande: json['typeDemande'] ?? '',
      priorite: json['priorite'] ?? '',
      statut: json['statut'] ?? '',
      description: json['description'] ?? '',
      dateSouhaitee: json['dateSouhaitee'],
      motifRejet: json['motifRejet'],
      ascenseurId: json['ascenseurId'],
      ascenseurNom: json['ascenseurNom'] ?? '',
      clientId: json['clientId'],
      clientNom: json['clientNom'] ?? '',
      createdAt: json['createdAt'],
      photos: json['photos'] ?? [],
    );
  }
}