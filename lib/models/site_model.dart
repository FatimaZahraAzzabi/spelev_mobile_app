import 'ville_model.dart';
import 'utilisateur_model.dart';
import 'parc_model.dart';

class SiteModel {
  final int id;
  final String adresse;
  final String? codePostal;
  final VilleModel? ville;
  final UtilisateurModel? client;
  final ParcModel? parc;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SiteModel({
    required this.id,
    required this.adresse,
    this.codePostal,
    this.ville,
    this.client,
    this.parc,
    this.createdAt,
    this.updatedAt,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'],
      adresse: json['adresse'] ?? '',
      codePostal: json['codePostal'],
      ville: json['ville'] != null ? VilleModel.fromJson(json['ville']) : null,
      client: json['client'] != null ? UtilisateurModel.fromJson(json['client']) : null,
      parc: json['parc'] != null ? ParcModel.fromJson(json['parc']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}