import 'package:flutter/material.dart';

enum TaskType {
  tugas('Tugas', Color(0xFF4F46E5)),
  kuis('Kuis', Color(0xFFD97706)),
  uts('UTS', Color(0xFFDC2626)),
  uas('UAS', Color(0xFF7C3AED));

  const TaskType(this.label, this.color);
  final String label;
  final Color color;
  bool get isExam => this != TaskType.tugas;
}

enum TaskPriority {
  rendah('Rendah', Color(0xFF16A34A)),
  sedang('Sedang', Color(0xFFD97706)),
  tinggi('Tinggi', Color(0xFFDC2626));

  const TaskPriority(this.label, this.color);
  final String label;
  final Color color;
}

class Task {
  const Task({
    this.id,
    required this.userId,
    required this.title,
    this.courseName = '',
    required this.due,
    this.type = TaskType.tugas,
    this.priority = TaskPriority.sedang,
    this.reminder = true,
    this.done = false,
    this.doneAt,
  });

  final int? id;
  final int userId;
  final String title;
  final String courseName;
  final DateTime due;
  final TaskType type;
  final TaskPriority priority;
  final bool reminder;
  final bool done;
  final DateTime? doneAt;

  Task withId(int newId) => Task(
        id: newId, userId: userId, title: title, courseName: courseName, due: due,
        type: type, priority: priority, reminder: reminder, done: done, doneAt: doneAt);

  /// Membalik status selesai sekaligus mencatat / menghapus waktu selesai.
  Task toggled() => Task(
        id: id, userId: userId, title: title, courseName: courseName, due: due,
        type: type, priority: priority, reminder: reminder,
        done: !done, doneAt: done ? null : DateTime.now());

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'course_name': courseName,
        'due': due.toIso8601String(),
        'type': type.name,
        'priority': priority.index,
        'reminder': reminder ? 1 : 0,
        'done': done ? 1 : 0,
        'done_at': doneAt?.toIso8601String(),
      };

  factory Task.fromMap(Map<String, Object?> m) => Task(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        title: m['title'] as String,
        courseName: (m['course_name'] as String?) ?? '',
        due: DateTime.parse(m['due'] as String),
        type: TaskType.values.byName(m['type'] as String),
        priority: TaskPriority.values[m['priority'] as int],
        reminder: (m['reminder'] as int) == 1,
        done: (m['done'] as int) == 1,
        doneAt: m['done_at'] == null ? null : DateTime.parse(m['done_at'] as String),
      );
}
