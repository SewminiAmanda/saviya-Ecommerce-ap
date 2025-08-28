import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:8080/api'; //10.0.2.2  / 192.168.247.158

  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/users/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  //get current user details
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['user'];
    } else {
      throw Exception('Failed to load user');
    }
  }

  //get all categories
 static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
    );

    print("Raw response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['categories']; 
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }


  // Fetch products by category ID
  static Future<List<dynamic>> fetchProductsByCategory(int categoryId) async {
    final url = Uri.parse('$baseUrl/product/category/$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['products'] ?? []; // Return products or empty list if none
    } else {
      throw Exception('Failed to load products');
    }
  }

  //fetch chat history
Future<List<Map<String, dynamic>>> fetchChatHistory(
    String user1,
    String user2,
  ) async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:8080/api/chat/history?user1=$user1&user2=$user2',
      ),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['messages']);
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  
}
