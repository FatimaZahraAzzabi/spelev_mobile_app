import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/assemblage_model.dart';

class AssemblageService {
  final String rootUrl = "http://192.168.1.27:8080/api";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  Future<List<AssemblageModel>> getArbreParAscenseur(int ascenseurId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$rootUrl/assemblages/ascenseur/$ascenseurId/arbre'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? json;
      return data.map((e) => AssemblageModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement arbre: ${response.statusCode}');
  }

  Future<AssemblageModel> creer(Map<String, dynamic> dto) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$rootUrl/assemblages'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return AssemblageModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur création: ${response.body}');
  }

  Future<void> supprimer(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$rootUrl/assemblages/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression');
    }
  }
  
}