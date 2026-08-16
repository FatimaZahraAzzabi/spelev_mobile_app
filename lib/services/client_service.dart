import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/client_model.dart';

class ClientService {
  final String baseUrl = "http://192.168.1.27:8080/api/utilisateurs"; 
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  // 1. Récupérer la liste des clients
  Future<List<ClientModel>> getClients() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      // On filtre pour ne garder que les clients (au cas où le backend renvoie tout)
      return data.where((json) => json['type'] == 'CLIENT').map((json) => ClientModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des clients: ${response.statusCode}');
    }
  }

  // 2. Créer un client
  Future<ClientModel> createClient(ClientModel client, String motDePasse) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(client.toMap(motDePasse: motDePasse)),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ClientModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Erreur création: ${response.body}');
    }
  }

  // 3. Modifier un client
  Future<ClientModel> updateClient(int id, ClientModel client, String? motDePasse) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(client.toMap(motDePasse: motDePasse)),
    );

    if (response.statusCode == 200) {
      return ClientModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Erreur modification: ${response.body}');
    }
  }
}