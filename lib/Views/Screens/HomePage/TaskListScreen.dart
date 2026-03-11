// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../Models/TaskModel.dart';
import '../../../Riverpordprovider/RiverpordProvider.dart';
import 'AddTaskScreen.dart';
import 'SharedWidget.dart';
import 'TaskDetailScreen.dart';


class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskProvider);

    // Show error as a snackbar when it surfaces
    // ref.listen<TaskListState>(taskProvider, (prev, next) {
    //   if (next.loadingState == LoadingState.error &&
    //       next.errorMessage != null &&
    //       prev?.errorMessage != next.errorMessage) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(next.errorMessage!),
    //         backgroundColor: Colors.red.shade700,
    //         behavior: SnackBarBehavior.floating,
    //         action: SnackBarAction(
    //           label: 'Dismiss',
    //           textColor: Colors.white,
    //           onPressed: () => ref.read(taskProvider.notifier).clearError(),
    //         ),
    //       ),
    //     );
    //   }
    // });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Field Service Tracker',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          if (state.loadingState == LoadingState.loading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          // else
          //   IconButton(
          //     icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
          //     onPressed: () => ref.read(taskProvider.notifier).fetchTasks(),
          //     tooltip: 'Refresh',
          //   ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(activeFilter: state.activeFilter),
          Expanded(
            child: _buildBody(context, ref, state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, TaskListState state) {
    if (state.loadingState == LoadingState.loading && state.tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB)),
            SizedBox(height: 16),
            Text('Loading tasks...', style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    if (state.loadingState == LoadingState.error && state.tasks.isEmpty) {
      // return Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(32),
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red.shade300),
      //         const SizedBox(height: 16),
      //         Text(
      //           state.errorMessage ?? 'Something went wrong.',
      //           textAlign: TextAlign.center,
      //           style: const TextStyle(color: Color(0xFF475569), fontSize: 15),
      //         ),
      //         const SizedBox(height: 24),
      //         FilledButton.icon(
      //           onPressed: () => ref.read(taskProvider.notifier).fetchTasks(),
      //           icon: const Icon(Icons.refresh_rounded),
      //           label: const Text('Try Again'),
      //           style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
      //         ),
      //       ],
      //     ),
      //   ),
      // );
    }

    final tasks = state.filteredTasks;
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              state.activeFilter != null
                  ? 'No ${state.activeFilter!.label} tasks.'
                  : 'No tasks yet. Create one!',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(taskProvider.notifier).fetchTasks(),
      color: const Color(0xFF2563EB),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _TaskCard(task: tasks[index]),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final TaskStatus? activeFilter;
  const _FilterBar({required this.activeFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _filterChip(ref, null, 'All'),
          const SizedBox(width: 8),
          _filterChip(ref, TaskStatus.pending, 'Pending'),
          const SizedBox(width: 8),
          _filterChip(ref, TaskStatus.inProgress, 'In Progress'),
          const SizedBox(width: 8),
          _filterChip(ref, TaskStatus.completed, 'Done'),
        ],
      ),
    );
  }

  Widget _filterChip(WidgetRef ref, TaskStatus? status, String label) {
    final isActive = activeFilter == status;
    return GestureDetector(
      onTap: () => ref.read(taskProvider.notifier).setFilter(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TaskPriorityBadge(priority: task.priority),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TaskStatusChip(status: task.status, compact: true),
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(task.assignedDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}