class AscenseurModel {
  final int id;
  final String nom;
  final bool actif;
  final String? marque;
  final String? fabricant;
  final String? modele;
  final String? numeroSerie;
  final String? codeBarre;
  final String? puissance;
  final int? nombreEtages;
  final int? capacitePersonnes;
  final double? chargeMaxKg;
  final double? vitesse;
  final String? description;
  final DateTime? dateMiseEnService;
  final DateTime? dateExpirationGarantie;

  final int? clientId;
  final String? clientPrenom;
  final String? clientNom;
  final String? clientNomEntreprise;
  
  final int? siteId;
  final String? siteAdresse;
  
  final int? parcId;
  final String? parcNom;

  AscenseurModel({
    required this.id,
    required this.nom,
    required this.actif,
    this.marque,
    this.fabricant,
    this.modele,
    this.numeroSerie,
    this.codeBarre,
    this.puissance,
    this.nombreEtages,
    this.capacitePersonnes,
    this.chargeMaxKg,
    this.vitesse,
    this.description,
    this.dateMiseEnService,
    this.dateExpirationGarantie,
    this.clientId,
    this.clientPrenom,
    this.clientNom,
    this.clientNomEntreprise,
    this.siteId,
    this.siteAdresse,
    this.parcId,
    this.parcNom,
  });

  factory AscenseurModel.fromJson(Map<String, dynamic> json) {
    return AscenseurModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? 'Sans nom',
      actif: json['actif'] ?? true,
      marque: json['marque'],
      fabricant: json['fabricant'],
      modele: json['modele'],
      numeroSerie: json['numeroSerie'],
      codeBarre: json['codeBarre'],
      puissance: json['puissance'],
      nombreEtages: json['nombreEtages'],
      capacitePersonnes: json['capacitePersonnes'],
      chargeMaxKg: (json['chargeMaxKg'] as num?)?.toDouble(),
      vitesse: (json['vitesse'] as num?)?.toDouble(),
      description: json['description'],
      dateMiseEnService: json['dateMiseEnService'] != null 
          ? DateTime.parse(json['dateMiseEnService']) 
          : null,
      dateExpirationGarantie: json['dateExpirationGarantie'] != null 
          ? DateTime.parse(json['dateExpirationGarantie']) 
          : null,
      
      // ✅ Lecture directe des champs à plat (pas de json['client']['...'])
      clientId: json['clientId'],
      clientPrenom: json['clientPrenom'],
      clientNom: json['clientNom'],
      clientNomEntreprise: json['clientNomEntreprise'],
      
      siteId: json['siteId'],
      siteAdresse: json['siteAdresse'],
      
      parcId: json['parcId'],
      parcNom: json['parcNom'],
    );
  }
}