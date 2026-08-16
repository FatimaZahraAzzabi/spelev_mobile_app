import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/demande_maintenance_model.dart';

class DemandeMaintenanceService {
  final String baseUrl = "http://192.168.1.27:8080/api/demandes-maintenance";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  // --- Côté Client ---
  Future<DemandeMaintenanceModel> creerDemande(Map<String, dynamic> dto) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return DemandeMaintenanceModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur création demande: ${response.body}');
  }

  Future<List<DemandeMaintenanceModel>> getMesDemandes() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/mes-demandes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? json;
      return data.map((e) => DemandeMaintenanceModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement demandes: ${response.statusCode}');
  }

  // --- Côté Responsable ---
  Future<List<DemandeMaintenanceModel>> getDemandesEnAttente() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/en-attente'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? json;
      return data.map((e) => DemandeMaintenanceModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement demandes en attente: ${response.statusCode}');
  }

  Future<DemandeMaintenanceModel> rejeterDemande(int id, String motif) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/rejeter'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'motif': motif}),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DemandeMaintenanceModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur rejet demande: ${response.body}');
  }
}