import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const daysShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  /// d = 1 (Senin) ... 7 (Minggu), sama dengan DateTime.weekday.
  static String dayName(int d) => days[(d - 1) % 7];

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String hm(DateTime d) => DateFormat('HH:mm').format(d);

  static String dueLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    final t = hm(d);
    if (diff == 0) return 'Hari ini, $t';
    if (diff == 1) return 'Besok, $t';
    if (diff == -1) return 'Kemarin, $t';
    if (diff > 1 && diff < 7) return '${days[d.weekday - 1]}, $t';
    return '${DateFormat('d MMM y', 'id_ID').format(d)}, $t';
  }

  static String timeToStr(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay strToTime(String s) {
    final p = s.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  static int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}
