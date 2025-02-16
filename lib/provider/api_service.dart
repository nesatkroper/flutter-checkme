class ApiService {
  static const String baseUrl =
      'https://express-checkme-production.up.railway.app/api';

  static Uri buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    return Uri.parse('$baseUrl/$endpoint')
        .replace(queryParameters: queryParams);
  }
}
