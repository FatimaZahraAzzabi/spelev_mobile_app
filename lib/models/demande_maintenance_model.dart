import 'piece_jointe_model.dart';

class DemandeMaintenanceModel {
  final int id;
  final String typeDemande;
  final String priorite;
  final String statut;
  final String description;
  final String? dateSouhaitee;
  final String? motifRejet;
  final int ascenseurId;
  final String? ascenseurNom;
  
  final int? clientId;
  final String? clientNom;
  final String? clientPrenom;
  final String? clientEmail;
  final String? clientNomEntreprise;
  
  final String? createdAt;
  final List<PieceJointeModel> photos;

  const DemandeMaintenanceModel({
    required this.id,
    required this.typeDemande,
    required this.priorite,
    required this.statut,
    required this.description,
    this.dateSouhaitee,
    this.motifRejet,
    required this.ascenseurId,
    this.ascenseurNom,
    this.clientId,
    this.clientNom,
    this.clientPrenom,
    this.clientEmail,
    this.clientNomEntreprise,
    this.createdAt,
    this.photos = const [],
  });

  // Getter pour le nom complet du client
  String get clientNomComplet {
    final nom = '${clientPrenom ?? ''} ${clientNom ?? ''}'.trim();
    if (nom.isEmpty) return clientNomEntreprise ?? 'Client inconnu';
    if (clientNomEntreprise != null && clientNomEntreprise!.isNotEmpty) {
      return '$nom ($clientNomEntreprise)';
    }
    return nom;
  }

  factory DemandeMaintenanceModel.fromJson(Map<String, dynamic> json) {
    // Parser les photos
    List<PieceJointeModel> photosList = [];
    final photosData = json['photos'] ?? json['piecesJointes'] ?? json['attachments'];
    if (photosData is List) {
      photosList = photosData
          .where((e) => e is Map)
          .map((e) => PieceJointeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Parser l'ascenseur
    int ascId = json['ascenseurId'] ?? 0;
    String? ascNom = json['ascenseurNom'];
    if (json['ascenseur'] is Map) {
      final asc = json['ascenseur'] as Map<String, dynamic>;
      ascId = asc['id'] ?? ascId;
      ascNom = asc['nom'] ?? ascNom;
    }

    int? clientId = json['clientId'];
    String? clientNom = json['clientNom'];
    String? clientPrenom = json['clientPrenom'];
    String? clientEmail = json['clientEmail'];
    String? clientNomEntreprise = json['clientNomEntreprise'];

    if (json['client'] is Map) {
      final client = json['client'] as Map<String, dynamic>;
      clientId ??= client['id'];
      clientNom ??= client['nom'];
      clientPrenom ??= client['prenom'];
      clientEmail ??= client['email'];
      clientNomEntreprise ??= client['nomEntreprise'];
    }

    return DemandeMaintenanceModel(
      id: json['id'] ?? 0,
      typeDemande: json['typeDemande'] ?? 'AUTRE',
      priorite: json['priorite'] ?? 'NORMALE',
      statut: json['statut'] ?? 'EN_ATTENTE',
      description: json['description'] ?? '',
      dateSouhaitee: json['dateSouhaitee'],
      motifRejet: json['motifRejet'],
      ascenseurId: ascId,
      ascenseurNom: ascNom,
      clientId: clientId,
      clientNom: clientNom,
      clientPrenom: clientPrenom,
      clientEmail: clientEmail,
      clientNomEntreprise: clientNomEntreprise,
      createdAt: json['createdAt'],
      photos: photosList,
    );
  }
}