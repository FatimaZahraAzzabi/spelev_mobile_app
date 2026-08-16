class BonTravailModel {
  final int id;
  final String statut;
  final String priorite;
  final String dateInterventionPrevue;
  final int dureeEstimeeMinutes;
  final String? description;
  final String? dateDebutReelle;
  final String? dateFinReelle;
  final String? diagnostic;
  final String? causeIdentifiee;
  final String? actionRealisee;
  final String? piecesRemplacees;
  final bool? essaiConcluant;
  final String? recommandations;
  final int? demandeMaintenanceId;
  final int ascenseurId;
  final String ascenseurNom;
  final String? siteAdresse;
  final int? parcId;
  final String? parcNom;
  final int technicienResponsableId;
  final String technicienResponsableNom;
  final List<dynamic> techniciens;
  final List<dynamic> photosDemande;
  final List<dynamic> piecesJointesBonTravail;

  BonTravailModel({
    required this.id,
    required this.statut,
    required this.priorite,
    required this.dateInterventionPrevue,
    required this.dureeEstimeeMinutes,
    this.description,
    this.dateDebutReelle,
    this.dateFinReelle,
    this.diagnostic,
    this.causeIdentifiee,
    this.actionRealisee,
    this.piecesRemplacees,
    this.essaiConcluant,
    this.recommandations,
    this.demandeMaintenanceId,
    required this.ascenseurId,
    required this.ascenseurNom,
    this.siteAdresse,
    this.parcId,
    this.parcNom,
    required this.technicienResponsableId,
    required this.technicienResponsableNom,
    this.techniciens = const [],
    this.photosDemande = const [],
    this.piecesJointesBonTravail = const [],
  });

  factory BonTravailModel.fromJson(Map<String, dynamic> json) {
    return BonTravailModel(
      id: json['id'],
      statut: json['statut'] ?? '',
      priorite: json['priorite'] ?? '',
      dateInterventionPrevue: json['dateInterventionPrevue'] ?? '',
      dureeEstimeeMinutes: json['dureeEstimeeMinutes'] ?? 0,
      description: json['description'],
      dateDebutReelle: json['dateDebutReelle'],
      dateFinReelle: json['dateFinReelle'],
      diagnostic: json['diagnostic'],
      causeIdentifiee: json['causeIdentifiee'],
      actionRealisee: json['actionRealisee'],
      piecesRemplacees: json['piecesRemplacees'],
      essaiConcluant: json['essaiConcluant'],
      recommandations: json['recommandations'],
      demandeMaintenanceId: json['demandeMaintenanceId'],
      ascenseurId: json['ascenseurId'],
      ascenseurNom: json['ascenseurNom'] ?? '',
      siteAdresse: json['siteAdresse'],
      parcId: json['parcId'],
      parcNom: json['parcNom'],
      technicienResponsableId: json['technicienResponsableId'],
      technicienResponsableNom: json['technicienResponsableNom'] ?? '',
      techniciens: json['techniciens'] ?? [],
      photosDemande: json['photosDemande'] ?? [],
      piecesJointesBonTravail: json['piecesJointesBonTravail'] ?? [],
    );
  }
}