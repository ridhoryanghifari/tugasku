import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_constants.dart';
import '../core/utils/date_helper.dart';
import '../data/models/course.dart';
import '../data/models/task.dart';

/// Notifikasi lokal untuk pengingat tenggat tugas/ujian dan jadwal kuliah.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(AppConstants.timeZone));
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      await requestPermission();
      _ready = true;
    } catch (e) {
      debugPrint('Notifikasi tidak aktif: $e');
    }
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final a = await android?.requestNotificationsPermission();
    final i = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return (a ?? i ?? true);
  }

  static Future<void> cancel(int id) async {
    if (!_ready) return;
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }

  /// Pengingat 1 hari sebelum tenggat (atau 1 jam sebelumnya bila sudah terlalu dekat).
  static Future<void> scheduleTask(Task t) async {
    if (!_ready || t.id == null) return;
    try {
      await _plugin.cancel(t.id!);
      if (t.done || !t.reminder) return;
      var when = t.due.subtract(const Duration(days: 1));
      if (when.isBefore(DateTime.now())) when = t.due.subtract(const Duration(hours: 1));
      if (when.isBefore(DateTime.now())) return;
      await _plugin.zonedSchedule(
        t.id!,
        '${t.type.label}: ${t.title}',
        'Tenggat ${DateHelper.dueLabel(t.due)}',
        tz.TZDateTime.from(when, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Gagal menjadwalkan tugas: $e');
    }
  }

  static int _courseNotifId(int courseId) => 1000000 + courseId;

  /// Pengingat mingguan 15 menit sebelum kuliah dimulai.
  static Future<void> scheduleCourse(Course c) async {
    if (!_ready || c.id == null) return;
    try {
      final nid = _courseNotifId(c.id!);
      await _plugin.cancel(nid);
      if (!c.reminder) return;
      final st = DateHelper.strToTime(c.start);
      // 1 Jan 2024 adalah hari Senin, sehingga (day - 1) memberi hari yang tepat.
      final r = DateTime(2024, 1, c.day, st.hour, st.minute)
          .subtract(const Duration(minutes: 15));
      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, r.hour, r.minute);
      while (next.weekday != r.weekday || next.isBefore(now)) {
        next = next.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        nid,
        'Kuliah ${c.name}',
        'Mulai ${c.start}${c.room.isEmpty ? '' : ' di ${c.room}'}',
        next,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Gagal menjadwalkan kuliah: $e');
    }
  }

  static Future<void> cancelCourse(int courseId) => cancel(_courseNotifId(courseId));
}
