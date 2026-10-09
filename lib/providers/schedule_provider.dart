import 'package:flutter/foundation.dart';

import '../data/models/course.dart';
import '../data/repositories/course_repository.dart';
import '../services/notification_service.dart';

class ScheduleProvider extends ChangeNotifier {
  ScheduleProvider(this._repo);
  final CourseRepository _repo;

  int? _userId;
  List<Course> _courses = [];
  List<Course> get courses => _courses;

  void setUser(int? id) {
    if (id == _userId) return;
    _userId = id;
    _courses = [];
    Future.microtask(load);
  }

  Future<void> load() async {
    _courses = _userId == null ? [] : await _repo.getAll(_userId!);
    notifyListeners();
    for (final c in _courses) {
      await NotificationService.scheduleCourse(c);
    }
  }

  void _sort() => _courses.sort((a, b) {
        final byDay = a.day.compareTo(b.day);
        return byDay != 0 ? byDay : a.start.compareTo(b.start);
      });

  Future<void> add(Course c) async {
    final id = await _repo.insert(c);
    final saved = c.copyWith(id: id);
    _courses = [..._courses, saved];
    _sort();
    notifyListeners();
    await NotificationService.scheduleCourse(saved);
  }

  /// Dipakai oleh fitur impor jadwal dari foto.
  Future<void> addAll(List<Course> list) async {
    for (final c in list) {
      final id = await _repo.insert(c);
      final saved = c.copyWith(id: id);
      _courses = [..._courses, saved];
      await NotificationService.scheduleCourse(saved);
    }
    _sort();
    notifyListeners();
  }

  Future<void> update(Course c) async {
    await _repo.update(c);
    _courses = [for (final x in _courses) x.id == c.id ? c : x];
    _sort();
    notifyListeners();
    await NotificationService.scheduleCourse(c);
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    _courses = _courses.where((c) => c.id != id).toList();
    notifyListeners();
    await NotificationService.cancelCourse(id);
  }

  Course? byId(int id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Course> coursesOn(int day) => _courses.where((c) => c.day == day).toList();
  List<Course> get today => coursesOn(DateTime.now().weekday);
  List<String> get names => _courses.map((c) => c.name).toSet().toList();
}
