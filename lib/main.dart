import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/sources/db_init.dart';
import 'providers/auth_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initDatabaseFactory(); // pilih SQLite sesuai platform (mobile / desktop / web)
  await initializeDateFormatting('id_ID');
  await NotificationService.init();

  final auth = AuthProvider(AuthRepository())..init();
  final settings = SettingsProvider()..load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (_) => TaskProvider(TaskRepository()),
          update: (_, a, p) => p!..setUser(a.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
          create: (_) => ScheduleProvider(CourseRepository()),
          update: (_, a, p) => p!..setUser(a.user?.id),
        ),
        ChangeNotifierProxyProvider<TaskProvider, CalendarProvider>(
          create: (_) => CalendarProvider(),
          update: (_, t, c) => c!..bind(t),
        ),
      ],
      child: TugasKuApp(auth: auth),
    ),
  );
}
