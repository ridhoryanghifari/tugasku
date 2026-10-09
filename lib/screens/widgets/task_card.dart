import 'package:flutter/material.dart';

import '../../core/utils/date_helper.dart';
import '../../data/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap, this.onToggle});

  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overdue = !task.done && task.due.isBefore(DateTime.now());
    final sub = task.courseName.isEmpty
        ? DateHelper.dueLabel(task.due)
        : '${DateHelper.dueLabel(task.due)} · ${task.courseName}';
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                    color: task.type.color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: overdue ? Colors.red : theme.hintColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Badge(task.type.label, task.type.color),
                  const SizedBox(height: 4),
                  _Badge(task.priority.label, task.priority.color),
                ],
              ),
              if (onToggle != null) Checkbox(value: task.done, onChanged: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      );
}
