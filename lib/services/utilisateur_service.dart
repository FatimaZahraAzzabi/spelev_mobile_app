import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/utilisateur_model.dart';

class UtilisateurService {
  final String baseUrl = "http://192.168.1.27:8080/api/utilisateurs";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Récupérer tous les utilisateurs
  Future<List<UtilisateurModel>> getUtilisateurs() async {
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
      return dataList.map((json) => UtilisateurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  // Récupérer un utilisateur par ID
  Future<UtilisateurModel> getUtilisateurById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return UtilisateurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  // Créer un utilisateur
  Future<UtilisateurModel> createUtilisateur(UtilisateurCreateDTO dto) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toMap()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return UtilisateurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  // Modifier un utilisateur
  Future<UtilisateurModel> updateUtilisateur(int id, UtilisateurUpdateDTO dto) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toMap()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return UtilisateurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUtilisateur(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<List<UtilisateurModel>> getResponsables() async {
  final token = await _getToken();
  if (token == null) throw Exception("Token manquant");

  final response = await http.get(
    Uri.parse('http://192.168.1.27:8080/api/utilisateurs'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
    
    // Filtrer uniquement les responsables
    return dataList
        .where((json) => json['type'] == 'RESPONSABLE_MAINTENANCE')
        .map((json) => UtilisateurModel.fromJson(json))
        .toList();
  } else {
    throw Exception('Erreur: ${response.statusCode}');
  }
}

  Future<List<UtilisateurModel>> getTechniciens() async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.get(
      Uri.parse('http://192.168.1.27:8080/api/utilisateurs'), // N'oublie pas de mettre ta bonne IP
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      
      // Filtrer uniquement les techniciens (adapte 'type' ou 'technicien' selon ton JSON)
      return dataList
          .where((json) => json['type'] == 'TECHNICIEN' || json['technicien'] != null) 
          .map((json) => UtilisateurModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

}