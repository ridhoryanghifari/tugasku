import 'package:flutter/foundation.dart';

import '../data/models/task.dart';
import 'task_provider.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  TaskProvider? _tasks;

  /// Dihubungkan ke TaskProvider lewat ProxyProvider (tanpa notifyListeners).
  void bind(TaskProvider t) => _tasks = t;

  List<Task> eventsOf(DateTime day) => _tasks?.tasksOn(day) ?? const [];

  void select(DateTime selected, DateTime focused) {
    selectedDay = selected;
    focusedDay = focused;
    notifyListeners();
  }

  void setFocused(DateTime focused) => focusedDay = focused;
}
