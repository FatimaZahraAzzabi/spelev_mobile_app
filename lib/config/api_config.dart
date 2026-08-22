import 'package:flutter/foundation.dart';

class ApiConfig {
  static const bool isProduction = kReleaseMode;

  // URL du Backend
  static String get baseUrl => isProduction
      ? 'https://api-siop.stage.enset.top'      
      : 'http://192.168.1.27:8080';           

  // URL de MinIO
  static String get minioUrl => isProduction
      ? 'https://minio-siop.stage.enset.top'    
      : 'http://192.168.1.27:9000';            

  static String fixMinioUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    return url
        .replaceAll('http://localhost:9000', minioUrl)
        .replaceAll('http://127.0.0.1:9000', minioUrl);
  }
}