import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ApiService {
  // Android emulator eken run karanawa nam 10.0.2.2 use karanna (localhost wenuwata)
  // Real device eken test karanawa nam computer eke local IP eka danna, e.g. http://192.168.1.5:5000
  // iOS simulator eken nam localhost eka hariyata work karayi
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ---------- Token storage ----------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ---------- Auth ----------
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) {
      await saveToken(data['token']);
      return {'success': true, 'data': data};
    }
    return {'success': false, 'message': data['message'] ?? 'Registration failed'};
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await saveToken(data['token']);
      return {'success': true, 'data': data};
    }
    return {'success': false, 'message': data['message'] ?? 'Login failed'};
  }

  // ---------- Tasks ----------
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Task>> getTasks({
    String? search,
    String? status, // 'all' | 'pending' | 'completed'
    String? category,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status != 'all') queryParams['status'] = status;
    if (category != null && category != 'All') queryParams['category'] = category;

    final uri = Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams);

    final res = await http.get(uri, headers: await _authHeaders());
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Task.fromJson(json)).toList();
    }
    throw Exception('Failed to load tasks');
  }

  static Future<List<String>> getCategories() async {
    final res = await http.get(
      Uri.parse('$baseUrl/tasks/categories'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  static Future<Task> createTask({
    required String title,
    String priority = 'medium',
    DateTime? dueDate,
    String category = 'General',
    String? notes,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'title': title,
        'priority': priority,
        'dueDate': dueDate != null ? dueDate.toIso8601String().split('T')[0] : null,
        'category': category,
        'notes': notes,
      }),
    );
    if (res.statusCode == 201) {
      return Task.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create task');
  }

  static Future<Task> updateTask(
    String id, {
    String? title,
    bool? completed,
    String? priority,
    DateTime? dueDate,
    String? category,
    String? notes,
    bool clearDueDate = false,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (completed != null) body['completed'] = completed;
    if (priority != null) body['priority'] = priority;
    if (category != null) body['category'] = category;
    if (notes != null) body['notes'] = notes;
    if (clearDueDate) {
      body['dueDate'] = null;
    } else if (dueDate != null) {
      body['dueDate'] = dueDate.toIso8601String().split('T')[0];
    }

    final res = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      return Task.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to update task');
  }

  static Future<void> deleteTask(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
