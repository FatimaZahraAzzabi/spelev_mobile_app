class ApiConfig {
  static const String baseUrl = 'http://192.168.1.27:8080';
  static const String minioUrl = 'http://192.168.1.27:9000';

  static String fixMinioUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url
        .replaceAll('http://localhost:9000', minioUrl)
        .replaceAll('http://127.0.0.1:9000', minioUrl);
  }
}