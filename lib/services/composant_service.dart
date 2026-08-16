import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/composant_model.dart';

class ComposantService {
  final String rootUrl = "http://192.168.1.27:8080/api";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  Future<List<ComposantModel>> getParAssemblage(int assemblageId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$rootUrl/composants/assemblage/$assemblageId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? json;
      return data.map((e) => ComposantModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement composants: ${response.statusCode}');
  }

  Future<ComposantModel> creer(Map<String, dynamic> dto) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$rootUrl/composants'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return ComposantModel.fromJson(json['data'] ?? json);
    }
    throw Exception('Erreur création: ${response.body}');
  }
}