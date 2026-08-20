import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/bon_travail_model.dart';
import '../models/bon_travail_create_model.dart';
import 'api_helper.dart';

class BonTravailService {
  Future<List<BonTravailModel>> lister() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/bons-travail'),
      headers: await ApiHelper.headers(),
    );
    ApiHelper.checkStatus(res);
    final data = ApiHelper.unwrap(res.body);
    return (data as List).map((e) => BonTravailModel.fromJson(e)).toList();
  }

  Future<List<BonTravailModel>> getMesInterventions() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/bons-travail/mes-interventions'),
      headers: await ApiHelper.headers(),
    );
    ApiHelper.checkStatus(res);
    final data = ApiHelper.unwrap(res.body);
    return (data as List).map((e) => BonTravailModel.fromJson(e)).toList();
  }

  Future<BonTravailModel> getDetail(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/bons-travail/$id'),
      headers: await ApiHelper.headers(),
    );
    ApiHelper.checkStatus(res);
    return BonTravailModel.fromJson(ApiHelper.unwrap(res.body));
  }

  Future<BonTravailModel> creer(BonTravailCreateModel dto) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/bons-travail'),
      headers: await ApiHelper.headers(),
      body: jsonEncode(dto.toJson()),
    );
    ApiHelper.checkStatus(res);
    return BonTravailModel.fromJson(ApiHelper.unwrap(res.body));
  }

  Future<BonTravailModel> annuler(int id) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/bons-travail/$id/annuler'),
      headers: await ApiHelper.headers(),
    );
    ApiHelper.checkStatus(res);
    return BonTravailModel.fromJson(ApiHelper.unwrap(res.body));
  }

  Future<List<Map<String, dynamic>>> verifierDisponibilite({
    required List<int> technicienIds,
    required DateTime debut,
    required int dureeMinutes,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/bons-travail/verifier-disponibilite')
        .replace(queryParameters: {
      'technicienIds': technicienIds.join(','),
      'debut': debut.toIso8601String(),
      'dureeMinutes': dureeMinutes.toString(),
    });

    final res = await http.get(uri, headers: await ApiHelper.headers());
    ApiHelper.checkStatus(res);
    final data = ApiHelper.unwrap(res.body);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getTechniciensDisponibles({
    required int ascenseurId,
    required DateTime debut,
    required int dureeMinutes,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/bons-travail/techniciens-disponibles')
        .replace(queryParameters: {
      'ascenseurId': ascenseurId.toString(),
      'debut': debut.toIso8601String(),
      'dureeMinutes': dureeMinutes.toString(),
    });

    final res = await http.get(uri, headers: await ApiHelper.headers());
    ApiHelper.checkStatus(res);
    final data = ApiHelper.unwrap(res.body);
    return List<Map<String, dynamic>>.from(data);
  }
}