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

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    if (token == null) throw Exception("Token manquant");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // 🔹 CÔTÉ CLIENT (utilise le token JWT pour filtrer)
  // ═══════════════════════════════════════════════════════════

  /// GET /api/ascenseurs/mes-ascenseurs
  /// Récupère les ascenseurs du CLIENT connecté (via token JWT)
  Future<List<AscenseurModel>> getMesAscenseurs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/mes-ascenseurs'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => AscenseurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  /// GET /api/ascenseurs/{id}
  /// Détail d'un ascenseur (utile côté client pour afficher les détails)
  Future<AscenseurModel> getDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AscenseurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔹 CÔTÉ ADMIN / RESPONSABLE MAINTENANCE
  // ═══════════════════════════════════════════════════════════

  /// GET /api/ascenseurs
  /// Liste TOUS les ascenseurs (admin/responsable)
  Future<List<AscenseurModel>> getAscenseurs() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => AscenseurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  /// GET /api/ascenseurs/client/{clientId}
  /// Ascenseurs d'un client spécifique (vue admin/responsable)
  Future<List<AscenseurModel>> getAscenseursParClient(int clientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/client/$clientId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => AscenseurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  /// GET /api/ascenseurs/site/{siteId}
  Future<List<AscenseurModel>> getAscenseursParSite(int siteId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/site/$siteId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => AscenseurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  /// POST /api/ascenseurs
  Future<AscenseurModel> createAscenseur(Map<String, dynamic> dto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode(dto),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return AscenseurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  /// PUT /api/ascenseurs/{id}
  Future<AscenseurModel> updateAscenseur(int id, Map<String, dynamic> dto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await _headers(),
      body: jsonEncode(dto),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AscenseurModel.fromJson(jsonResponse['data'] ?? jsonResponse);
    } else {
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  /// DELETE /api/ascenseurs/{id}
  Future<void> deleteAscenseur(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔹 MÉTHODES LIÉES (clients & sites)
  // ═══════════════════════════════════════════════════════════

  /// GET /api/utilisateurs/clients
  Future<List<UtilisateurModel>> getClients() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.27:8080/api/utilisateurs/clients'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => UtilisateurModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  /// GET /api/sites/client/{clientId}
  Future<List<SiteModel>> getSitesByClient(int clientId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.27:8080/api/sites/client/$clientId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> dataList = jsonResponse['data'] ?? jsonResponse;
      return dataList.map((json) => SiteModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }
}