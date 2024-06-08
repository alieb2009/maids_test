import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maids/models/task.dart';

class TaskService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final tasksJson = jsonResponse['todos'] as List;

      return tasksJson.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}
