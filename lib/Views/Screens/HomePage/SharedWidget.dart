// lib/widgets/task_status_chip.dart

import 'package:flutter/material.dart';
import '../../../Models/TaskModel.dart';

class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const TaskStatusChip({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, icon) = switch (status) {
      TaskStatus.pending => (
      const Color(0xFFB45309),
      const Color(0xFFFEF3C7),
      Icons.schedule_rounded,
      ),
      TaskStatus.inProgress => (
      const Color(0xFF1D4ED8),
      const Color(0xFFDBEAFE),
      Icons.sync_rounded,
      ),
      TaskStatus.completed => (
      const Color(0xFF065F46),
      const Color(0xFFD1FAE5),
      Icons.check_circle_rounded,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskPriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const TaskPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      TaskPriority.low => (const Color(0xFF6B7280), 'LOW'),
      TaskPriority.medium => (const Color(0xFFD97706), 'MED'),
      TaskPriority.high => (const Color(0xFFDC2626), 'HIGH'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}