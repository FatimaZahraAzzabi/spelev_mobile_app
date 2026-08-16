class ChecklistModel {
  final int id;
  final int mois;
  final int annee;
  final int ascenseurId;
  final String ascenseurNom;
  final int? bonTravailId;
  final int? technicienId;
  final String? technicienNom;
  final String? heureArrivee;
  final String? heureDepart;
  final bool estMaintenance;
  final bool estDepannage;
  final bool estTravaux;
  final String? bilanIntervention;
  final List<ItemChecklistModel> items;

  ChecklistModel({
    required this.id,
    required this.mois,
    required this.annee,
    required this.ascenseurId,
    required this.ascenseurNom,
    this.bonTravailId,
    this.technicienId,
    this.technicienNom,
    this.heureArrivee,
    this.heureDepart,
    required this.estMaintenance,
    required this.estDepannage,
    required this.estTravaux,
    this.bilanIntervention,
    this.items = const [],
  });

  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    return ChecklistModel(
      id: json['id'],
      mois: json['mois'],
      annee: json['annee'],
      ascenseurId: json['ascenseurId'],
      ascenseurNom: json['ascenseurNom'] ?? '',
      bonTravailId: json['bonTravailId'],
      technicienId: json['technicienId'],
      technicienNom: json['technicienNom'],
      heureArrivee: json['heureArrivee'],
      heureDepart: json['heureDepart'],
      estMaintenance: json['estMaintenance'] ?? false,
      estDepannage: json['estDepannage'] ?? false,
      estTravaux: json['estTravaux'] ?? false,
      bilanIntervention: json['bilanIntervention'],
      items: (json['items'] as List?)
              ?.map((e) => ItemChecklistModel.fromJson(e))
              .toList() ?? [],
    );
  }
}

class ItemChecklistModel {
  final int id;
  final int ordre;
  final String libelle;
  final String statut; 
  final String? gravite;
  final String? remarque;
  final List<dynamic> piecesJointes;

  ItemChecklistModel({
    required this.id,
    required this.ordre,
    required this.libelle,
    required this.statut,
    this.gravite,
    this.remarque,
    this.piecesJointes = const [],
  });

  factory ItemChecklistModel.fromJson(Map<String, dynamic> json) {
    return ItemChecklistModel(
      id: json['id'],
      ordre: json['ordre'],
      libelle: json['libelle'] ?? '',
      statut: json['statut'] ?? 'NON_VERIFIE',
      gravite: json['gravite'],
      remarque: json['remarque'],
      piecesJointes: json['piecesJointes'] ?? [],
    );
  }
}