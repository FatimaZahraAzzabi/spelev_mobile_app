import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ AJOUTE CET IMPORT
import '../models/parc_model.dart';

class ParcService {
  final String baseUrl = 'http://192.168.1.27:8080/api/parcs';
  final _storage = const FlutterSecureStorage(); // ✅ Instance du stockage

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<List<ParcModel>> getParcs() async {
    final token = await _getToken();
    
    if (token == null) throw Exception("Utilisateur non connecté (Token manquant)");

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => ParcModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement parcs: ${response.statusCode} - ${response.body}');
    }
  }

  Future<ParcModel> createParc(String nom) async {
    final token = await _getToken();
    if (token == null) throw Exception("Utilisateur non connecté (Token manquant)");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nom': nom}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return ParcModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur création parc: ${response.statusCode} - ${response.body}');
    }
  }
}