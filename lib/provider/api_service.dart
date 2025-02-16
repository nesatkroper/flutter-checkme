class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Uri buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    return Uri.parse('$baseUrl/$endpoint')
        .replace(queryParameters: queryParams);
  }
}
