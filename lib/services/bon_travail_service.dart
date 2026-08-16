import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/bon_travail_model.dart';

class BonTravailService {
  final String baseUrl = "http://192.168.1.27:8080/api/bons-travail";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  // --- Côté Responsable ---
  Future<BonTravailModel> creerBonTravail(Map<String, dynamic> dto) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return BonTravailModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur création bon de travail: ${response.body}');
  }

  Future<List<BonTravailModel>> listerBonsTravail() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? json;
      return data.map((e) => BonTravailModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement bons de travail: ${response.statusCode}');
  }

  // --- Côté Technicien ---
  Future<List<BonTravailModel>> getMesInterventions() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/mes-interventions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? json;
      return data.map((e) => BonTravailModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement mes interventions: ${response.statusCode}');
  }

  Future<BonTravailModel> demarrerIntervention(int id) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/demarrer'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BonTravailModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur démarrage: ${response.body}');
  }

  Future<BonTravailModel> terminerIntervention(int id, Map<String, dynamic> dto) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/terminer'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BonTravailModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur clôture: ${response.body}');
  }
}