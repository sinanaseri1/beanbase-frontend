import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart'; // For multipart MediaType
import 'package:file_picker/file_picker.dart'; // Optional for picking files
import 'dart:typed_data';

import 'auth_service.dart';

class ApiService {
  /// Your server's base URL
  static const String apiBaseUrl = 'http://localhost:3000';

  // -------------------------
  // AUTH ENDPOINTS
  // -------------------------

  /// Sign up a user.
  static Future<Map<String, dynamic>> signup(
      String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  /// Log in a user and store the token in [AuthService].
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // -------------------------
  // COFFEE ENDPOINTS
  // -------------------------

  /// Fetch all coffees.
  static Future<List<dynamic>> fetchCoffees() async {
    final url = Uri.parse('$apiBaseUrl/coffees');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error fetching coffees. Status: ${response.statusCode}');
  }

  /// Create coffee without an image.
  static Future<Map<String, dynamic>> createCoffee({
    required String name,
    required String brand,
    required String roastLevel,
    required String tasteNotes,
    String? origin,
    String? description,
  }) async {
    final token = AuthService.authToken;
    if (token == null) {
      throw Exception('Not authenticated. Please log in first.');
    }

    final url = Uri.parse('$apiBaseUrl/coffees');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'brand': brand,
        'roast_level': roastLevel,
        'taste_notes': tasteNotes,
        'origin': origin ?? '',
        'description': description ?? '',
      }),
    );
    return jsonDecode(response.body);
  }

  /// Create coffee with an uploaded image using multipart/form-data.
  static Future<Map<String, dynamic>> createCoffeeWithImage({
    required String name,
    required String brand,
    required String roastLevel,
    required String tasteNotes,
    String? origin,
    String? description,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final token = AuthService.authToken;
    if (token == null) {
      throw Exception('Not authenticated. Please log in first.');
    }

    final url = Uri.parse('$apiBaseUrl/coffees/upload');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Add fields
    request.fields['name'] = name;
    request.fields['brand'] = brand;
    request.fields['roast_level'] = roastLevel;
    request.fields['taste_notes'] = tasteNotes;
    if (origin != null) request.fields['origin'] = origin;
    if (description != null) request.fields['description'] = description;

    // Add the image file
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'), // or image/png
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }
}
