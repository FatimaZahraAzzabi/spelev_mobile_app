import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/ascenseur_model.dart';
import '../models/utilisateur_model.dart';
import '../models/site_model.dart';

class AscenseurService {
  final String baseUrl = "http://192.168.1.27:8080/api/ascenseurs";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<List<AscenseurModel>> getAscenseurs() async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

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
      return dataList.map((json) => AscenseurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<List<UtilisateurModel>> getClients() async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.get(
      Uri.parse('http://192.168.1.27:8080/api/utilisateurs/clients'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => UtilisateurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<List<SiteModel>> getSitesByClient(int clientId) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.get(
      Uri.parse('http://192.168.1.27:8080/api/sites/client/$clientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => SiteModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<AscenseurModel> createAscenseur(Map<String, dynamic> dto) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return AscenseurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  Future<AscenseurModel> updateAscenseur(int id, Map<String, dynamic> dto) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AscenseurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteAscenseur(int id) async {
  final token = await _getToken();
  if (token == null) throw Exception("Token manquant");

  final response = await http.delete(
    Uri.parse('$baseUrl/$id'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Erreur lors de la suppression: ${response.statusCode}');
  }
}

}