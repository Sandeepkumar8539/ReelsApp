// lib/models/task.dart

enum TaskStatus { pending, inProgress, completed }

enum TaskPriority { low, medium, high }

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  String get apiValue {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime assignedDate;
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedDate,
    this.dueDate,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? assignedDate,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedDate: assignedDate ?? this.assignedDate,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Maps JSONPlaceholder /todos response to Task
  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final completed = json['completed'] as bool? ?? false;
    return Task(
      id: id,
      title: json['title'] as String? ?? 'Untitled Task',
      description:
      'Task #$id assigned to user ${json['userId']}. Tap to view full details and update status.',
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      priority: _priorityFromId(json['id'] as int? ?? 1),
      assignedDate: DateTime.now().subtract(Duration(days: (json['id'] as int? ?? 1) % 10)),
      dueDate: DateTime.now().add(Duration(days: (json['id'] as int? ?? 1) % 7 + 1)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status.apiValue,
    'priority': priority.label.toLowerCase(),
    'assignedDate': assignedDate.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
  };

  static TaskPriority _priorityFromId(int id) {
    if (id % 3 == 0) return TaskPriority.high;
    if (id % 3 == 1) return TaskPriority.medium;
    return TaskPriority.low;
  }
}