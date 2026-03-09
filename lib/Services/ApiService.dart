// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../Models/TaskModel.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const _timeoutDuration = Duration(seconds: 10);

  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/todos?_limit=20'))
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => Task.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          '',
        );
      }
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on HttpException {
      throw const ApiException('Unable to reach server. Please try again later.');
    } on FormatException {
      throw const ApiException('Unexpected response format from server.');
    }
  }

  /// Simulates a PATCH /todos/:id to update status.
  /// JSONPlaceholder accepts the request and echoes back the body.
  Future<Task> updateTaskStatus(Task task, TaskStatus newStatus) async {
    try {
      final updatedTask = task.copyWith(status: newStatus);
      final response = await _client
          .patch(
        Uri.parse('$_baseUrl/todos/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'completed': newStatus == TaskStatus.completed}),
      )
          .timeout(_timeoutDuration);

      // JSONPlaceholder returns 200 for existing IDs (1–200)
      if (response.statusCode == 200) {
        return updatedTask;
      } else {
        throw ApiException(
          'Failed to update task. Server returned ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on HttpException {
      throw const ApiException('Unable to reach server. Please try again later.');
    }
  }

  /// Simulates POST /todos to create a task.
  /// JSONPlaceholder echoes back with id: 201 for new items.
  Future<Task> createTask(Task task) async {
    try {
      final response = await _client
          .post(
        Uri.parse('$_baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()),
      )
          .timeout(_timeoutDuration);

      if (response.statusCode == 201) {
        // JSONPlaceholder returns id=201 for new todos — use local task id
        return task;
      } else {
        throw ApiException(
          'Failed to create task. Server returned ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on HttpException {
      throw const ApiException('Unable to reach server. Please try again later.');
    }
  }
}