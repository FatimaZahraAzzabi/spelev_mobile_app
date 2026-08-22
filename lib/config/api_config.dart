import 'package:flutter/foundation.dart'; 

class ApiConfig {
  static const bool isProduction = kReleaseMode;

  // URL du Backend
  static String get baseUrl => isProduction
      ? 'https://api.spelev.com'          
      : 'http://192.168.1.27:8080';     

  // URL de MinIO
  static String get minioUrl => isProduction
      ? 'https://storage.spelev.com'      //  URL Minio de PRODUCTION 
      : 'http://192.168.1.27:9000';       // URL Minio de DÉVELOPPEMENT 

  static String fixMinioUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    return url
        .replaceAll('http://localhost:9000', minioUrl)
        .replaceAll('http://127.0.0.1:9000', minioUrl);
  }
}