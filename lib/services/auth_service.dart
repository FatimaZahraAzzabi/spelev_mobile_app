import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://192.168.1.27:8080/api/auth";

  Future<Map<String, dynamic>?> login(String email, String motDePasse) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      print(" Tentative de connexion pour : $email");
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "motDePasse": motDePasse}),
      );

      print("📥 Réponse du serveur - Status: ${response.statusCode}");
      print("📄 Corps de la réponse: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("✅ Réponse décodée: $jsonResponse");
        
        // La réponse est probablement structurée comme: {"success": true, "data": {...}, "message": "..."}
        return jsonResponse['data']; 
      } else {
        print("❌ Erreur HTTP ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("💥 Exception: $e");
      return null;
    }
  }
}