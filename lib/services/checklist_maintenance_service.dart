import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/checklist_model.dart';

class ChecklistMaintenanceService {
  final String baseUrl = "http://192.168.1.27:8080/api/checklists";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  Future<ChecklistModel> getChecklistParBonTravail(int bonTravailId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/par-bon-travail/$bonTravailId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChecklistModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur chargement checklist: ${response.statusCode}');
  }

  Future<ChecklistModel> demarrerChecklist(int id) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/demarrer'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChecklistModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur démarrage checklist: ${response.body}');
  }

  Future<ChecklistModel> cocherItem(int itemId, Map<String, dynamic> dto) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/items/$itemId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChecklistModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur mise à jour item: ${response.body}');
  }

  Future<ChecklistModel> cloturerChecklist(int id, Map<String, dynamic> dto) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/cloturer'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChecklistModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur clôture checklist: ${response.body}');
  }
}