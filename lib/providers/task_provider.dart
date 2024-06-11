import 'package:flutter/material.dart';
import 'package:maids/models/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  int _totalTasks = 0;
  int _currentPage = 0;
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    loadTasksFromLocalStorage();
  }

  Future<void> fetchTasks({bool loadMore = false, required int limit}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      if (!loadMore) {
        _tasks = [];
        _currentPage = 0;
      }
      final response = await http.get(Uri.parse('https://dummyjson.com/todos?skip=${_currentPage * (limit+1)}&limit=${limit+1}'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> tasksJson = data['todos'];
        _totalTasks = data['total'];
        List<Task> fetchedTasks = tasksJson.map((task) => Task.fromJson(task)).toList();
        _tasks.addAll(fetchedTasks);
        _currentPage++;
        saveTasksToLocalStorage();  // Save tasks to local storage
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (error) {
      print('Error loading tasks: $error');
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTasks(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    saveTasksToLocalStorage();
    notifyListeners();
  }

  void updateTask(Task task) {
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      saveTasksToLocalStorage();
      notifyListeners();
    }
  }

  void toggleTaskStatus(int taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = Task(
        id: _tasks[index].id,
        todo: _tasks[index].todo,
        completed: !_tasks[index].completed,
        userId: _tasks[index].userId,
      );
      saveTasksToLocalStorage();
      notifyListeners();
    }
  }

  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
    saveTasksToLocalStorage();
    notifyListeners();
  }

  // Save tasks to local storage
  Future<void> saveTasksToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = _tasks.map((task) => json.encode(task.toJson())).toList();
    prefs.setStringList('tasks', tasksJson);
  }

  // Load tasks from local storage
  Future<void> loadTasksFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = prefs.getStringList('tasks') ?? [];
    List<Task> loadedTasks = tasksJson.map((task) => Task.fromJson(json.decode(task))).toList();
    setTasks(loadedTasks);
  }
}
