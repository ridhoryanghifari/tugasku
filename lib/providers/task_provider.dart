import 'package:flutter/foundation.dart';

import '../core/utils/date_helper.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import '../services/notification_service.dart';

enum TaskFilter { semua, aktif, selesai }

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._repo);
  final TaskRepository _repo;

  int? _userId;
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  /// Dipanggil ketika pengguna berganti (login/logout).
  void setUser(int? id) {
    if (id == _userId) return;
    _userId = id;
    _tasks = [];
    Future.microtask(load);
  }

  Future<void> load() async {
    _tasks = _userId == null ? [] : await _repo.getAll(_userId!);
    notifyListeners();
    for (final t in _tasks) {
      await NotificationService.scheduleTask(t);
    }
  }

  void _sort() => _tasks.sort((a, b) => a.due.compareTo(b.due));

  Future<void> add(Task t) async {
    final id = await _repo.insert(t);
    final saved = t.withId(id);
    _tasks = [..._tasks, saved];
    _sort();
    notifyListeners();
    await NotificationService.scheduleTask(saved);
  }

  Future<void> update(Task t) async {
    await _repo.update(t);
    _tasks = [for (final x in _tasks) x.id == t.id ? t : x];
    _sort();
    notifyListeners();
    await NotificationService.scheduleTask(t);
  }

  Future<void> toggleDone(Task t) => update(t.toggled());

  Future<void> delete(int id) async {
    await _repo.delete(id);
    _tasks = _tasks.where((t) => t.id != id).toList();
    notifyListeners();
    await NotificationService.cancel(id);
  }

  Task? byId(int id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Task> filter({String query = '', TaskFilter filter = TaskFilter.semua}) {
    final q = query.trim().toLowerCase();
    return _tasks.where((t) {
      final okFilter = switch (filter) {
        TaskFilter.semua => true,
        TaskFilter.aktif => !t.done,
        TaskFilter.selesai => t.done,
      };
      final okQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.courseName.toLowerCase().contains(q);
      return okFilter && okQuery;
    }).toList();
  }

  List<Task> upcoming(int n) => _tasks.where((t) => !t.done).take(n).toList();

  List<Task> tasksOn(DateTime day) =>
      _tasks.where((t) => DateHelper.isSameDay(t.due, day)).toList();

  List<Task> get todayTasks => tasksOn(DateTime.now());

  int get doneCount => _tasks.where((t) => t.done).length;
  int get activeCount => _tasks.where((t) => !t.done).length;
  int get upcomingExams => _tasks
      .where((t) => t.type.isExam && !t.done && t.due.isAfter(DateTime.now()))
      .length;

  /// Jumlah tugas selesai per hari pada minggu ini (indeks 0 = Senin).
  List<int> doneThisWeek() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final counts = List<int>.filled(7, 0);
    for (final t in _tasks) {
      final d = t.doneAt;
      if (!t.done || d == null) continue;
      final diff = DateTime(d.year, d.month, d.day).difference(monday).inDays;
      if (diff >= 0 && diff < 7) counts[diff]++;
    }
    return counts;
  }
}
