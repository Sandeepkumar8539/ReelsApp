// lib/providers/task_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Models/TaskModel.dart';
import '../Services/ApiService.dart';


// ── Service provider ──────────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// ── Task list state ───────────────────────────────────────────────────────────

enum LoadingState { idle, loading, success, error }

class TaskListState {
  final List<Task> tasks;
  final LoadingState loadingState;
  final String? errorMessage;
  final TaskStatus? activeFilter;

  const TaskListState({
    this.tasks = const [],
    this.loadingState = LoadingState.idle,
    this.errorMessage,
    this.activeFilter,
  });

  List<Task> get filteredTasks {
    if (activeFilter == null) return tasks;
    return tasks.where((t) => t.status == activeFilter).toList();
  }

  TaskListState copyWith({
    List<Task>? tasks,
    LoadingState? loadingState,
    String? errorMessage,
    TaskStatus? activeFilter,
    bool clearFilter = false,
    bool clearError = false,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TaskNotifier extends StateNotifier<TaskListState> {
  final ApiService _apiService;

  TaskNotifier(this._apiService) : super(const TaskListState()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(loadingState: LoadingState.loading, clearError: true);
    try {
      final tasks = await _apiService.fetchTasks();
      state = state.copyWith(tasks: tasks, loadingState: LoadingState.success);
    } on ApiException catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> updateTaskStatus(Task task, TaskStatus newStatus) async {
    try {
      final updated = await _apiService.updateTaskStatus(task, newStatus);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == task.id ? updated : t).toList(),
      );
    } on ApiException catch (e) {
      // Surface the error without losing existing list state
      state = state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: e.message,
      );
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final created = await _apiService.createTask(task);
      state = state.copyWith(tasks: [created, ...state.tasks]);
    } on ApiException catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: e.message,
      );
    }
  }

  void setFilter(TaskStatus? filter) {
    if (filter == state.activeFilter) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(activeFilter: filter);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, loadingState: LoadingState.success);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final taskProvider = StateNotifierProvider<TaskNotifier, TaskListState>((ref) {
  return TaskNotifier(ref.watch(apiServiceProvider));
});