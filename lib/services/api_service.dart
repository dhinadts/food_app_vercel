import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://YOUR_VERCEL_APP.vercel.app');

  static Future<List<dynamic>> search(String query) async {
    final resp = await http.post(Uri.parse('$baseUrl/api/search'), headers: {'Content-Type':'application/json'}, body: jsonEncode({'query':query}));
    if (resp.statusCode==200) return List<dynamic>.from(jsonDecode(resp.body));
    throw Exception('Search failed: ${resp.statusCode}');
  }

  static Future<List<dynamic>> recommend(List<double> lastEmbedding) async {
    final resp = await http.post(Uri.parse('$baseUrl/api/recommend'), headers: {'Content-Type':'application/json'}, body: jsonEncode({'lastDishEmbedding': lastEmbedding}));
    if (resp.statusCode==200) return List<dynamic>.from(jsonDecode(resp.body));
    throw Exception('Recommend failed');
  }

  static Future<String> chatbot(String prompt) async {
    final resp = await http.post(Uri.parse('$baseUrl/api/chatbot'), headers: {'Content-Type':'application/json'}, body: jsonEncode({'userPrompt': prompt}));
    if (resp.statusCode==200) {
      final d = jsonDecode(resp.body);
      return d['reply'] ?? '';
    }
    throw Exception('Chatbot failed');
  }
}
