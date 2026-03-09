// lib/screens/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../Models/TaskModel.dart';
import '../../../Riverpordprovider/RiverpordProvider.dart';
import 'SharedWidget.dart';


class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isUpdating = false;

  Task? _getTask(TaskListState state) {
    try {
      return state.tasks.firstWhere((t) => t.id == widget.taskId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateStatus(Task task, TaskStatus newStatus) async {
    setState(() => _isUpdating = true);
    await ref.read(taskProvider.notifier).updateTaskStatus(task, newStatus);
    if (mounted) {
      setState(() => _isUpdating = false);
      final state = ref.read(taskProvider);
      if (state.loadingState != LoadingState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to "${newStatus.label}"'),
            backgroundColor: const Color(0xFF065F46),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskProvider);
    final task = _getTask(state);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Detail')),
        body: const Center(child: Text('Task not found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Task Detail',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TaskPriorityBadge(priority: task.priority),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TaskStatusChip(status: task.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Description card
            _InfoCard(
              title: 'Description',
              icon: Icons.notes_rounded,
              child: Text(
                task.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Dates card
            _InfoCard(
              title: 'Timeline',
              icon: Icons.date_range_rounded,
              child: Column(
                children: [
                  _DateRow(
                    label: 'Assigned',
                    date: task.assignedDate,
                    icon: Icons.assignment_ind_rounded,
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 12),
                    _DateRow(
                      label: 'Due',
                      date: task.dueDate!,
                      icon: Icons.event_rounded,
                      highlight: task.dueDate!.isBefore(DateTime.now()) &&
                          task.status != TaskStatus.completed,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action button
            if (task.status != TaskStatus.completed) ...[
              _UpdateStatusButton(
                task: task,
                isUpdating: _isUpdating,
                onUpdate: _updateStatus,
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Color(0xFF065F46), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Task Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF065F46),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;
  final bool highlight;

  const _DateRow({
    required this.label,
    required this.date,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFFDC2626) : const Color(0xFF475569);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          DateFormat('EEEE, MMM d, yyyy').format(date),
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _UpdateStatusButton extends StatelessWidget {
  final Task task;
  final bool isUpdating;
  final Future<void> Function(Task, TaskStatus) onUpdate;

  const _UpdateStatusButton({
    required this.task,
    required this.isUpdating,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final nextStatus = task.status == TaskStatus.pending
        ? TaskStatus.inProgress
        : TaskStatus.completed;

    final (label, icon, color) = switch (nextStatus) {
      TaskStatus.inProgress => (
      'Mark as In Progress',
      Icons.play_arrow_rounded,
      const Color(0xFF1D4ED8),
      ),
      TaskStatus.completed => (
      'Mark as Completed',
      Icons.check_rounded,
      const Color(0xFF059669),
      ),
      _ => ('Update Status', Icons.update_rounded, const Color(0xFF2563EB)),
    };

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isUpdating ? null : () => onUpdate(task, nextStatus),
        icon: isUpdating
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(icon),
        label: Text(isUpdating ? 'Updating...' : label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}