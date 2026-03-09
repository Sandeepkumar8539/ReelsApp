// test/task_model_test.dart

import 'package:flutter_test/flutter_test.dart';

import '../../../Models/TaskModel.dart';

void main() {
  group('Task model', () {
    final baseTask = Task(
      id: '1',
      title: 'Inspect Valve',
      description: 'Check valve pressure at Site A.',
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      assignedDate: DateTime(2024, 1, 15),
      dueDate: DateTime(2024, 1, 20),
    );

    test('copyWith updates only specified fields', () {
      final updated = baseTask.copyWith(status: TaskStatus.completed);
      expect(updated.status, TaskStatus.completed);
      expect(updated.title, baseTask.title);
      expect(updated.id, baseTask.id);
    });

    test('fromJson maps JSONPlaceholder todo correctly', () {
      final json = {'id': 3, 'userId': 1, 'title': 'Test task', 'completed': true};
      final task = Task.fromJson(json);
      expect(task.status, TaskStatus.completed);
      expect(task.title, 'Test task');
      // id=3, 3%3==0 → high priority
      expect(task.priority, TaskPriority.high);
    });

    test('fromJson maps incomplete todo to pending', () {
      final json = {'id': 1, 'userId': 1, 'title': 'Pending task', 'completed': false};
      final task = Task.fromJson(json);
      expect(task.status, TaskStatus.pending);
    });

    test('TaskStatus.label returns correct string', () {
      expect(TaskStatus.pending.label, 'Pending');
      expect(TaskStatus.inProgress.label, 'In Progress');
      expect(TaskStatus.completed.label, 'Completed');
    });

    test('TaskStatus.apiValue returns snake_case string', () {
      expect(TaskStatus.inProgress.apiValue, 'in_progress');
    });

    test('toJson serializes correctly', () {
      final json = baseTask.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Inspect Valve');
      expect(json['status'], 'pending');
      expect(json['priority'], 'high');
    });
  });
}