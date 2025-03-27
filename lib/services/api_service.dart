import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'auth_service.dart';

/// Handles all API calls.
class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // ---------- AUTH ----------

  static Future<Map<String, dynamic>> signup(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ---------- COFFEES ----------

  static Future<List<dynamic>> fetchCoffees() async {
    final url = Uri.parse('$baseUrl/coffees');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error fetching coffees.');
  }

  static Future<Map<String, dynamic>> fetchCoffeeById(String coffeeId) async {
    final url = Uri.parse('$baseUrl/coffees/$coffeeId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Coffee not found.');
  }

  static Future<Map<String, dynamic>> createCoffee(
      Map<String, dynamic> data) async {
    final token = AuthService.authToken;
    if (token == null) throw Exception('Not authenticated.');
    final url = Uri.parse('$baseUrl/coffees');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createCoffeeWithImage({
    required Map<String, dynamic> data,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final token = AuthService.authToken;
    if (token == null) throw Exception('Not authenticated.');
    final url = Uri.parse('$baseUrl/coffees/upload');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      request.fields[key] = value?.toString() ?? '';
    });

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createReview(
      Map<String, dynamic> reviewData) async {
    final token = AuthService.authToken;
    if (token == null) throw Exception('Not authenticated.');
    final url = Uri.parse('$baseUrl/reviews');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reviewData),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> fetchReviewsForCoffee(String coffeeId) async {
    final url = Uri.parse('$baseUrl/reviews/coffee/$coffeeId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error fetching reviews.');
  }
}
