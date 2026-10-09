import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/main_shell.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/schedule/course_form_screen.dart';
import '../../screens/schedule/import_review_screen.dart';
import '../../screens/schedule/import_screen.dart';
import '../../screens/schedule/schedule_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/tasks/task_form_screen.dart';
import '../../screens/tasks/task_list_screen.dart';
import '../utils/schedule_parser.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!auth.initialized) return loc == '/splash' ? null : '/splash';
      final atAuth = loc == '/login' || loc == '/register';
      if (!auth.isLoggedIn) return atAuth ? null : '/login';
      if (loc == '/splash' || atAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Halaman di luar bottom navigation (tampil penuh di atas shell).
      GoRoute(
        path: '/tasks/form',
        builder: (_, s) => TaskFormScreen(
          id: int.tryParse(s.uri.queryParameters['id'] ?? ''),
          initialDate: DateTime.tryParse(s.uri.queryParameters['date'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/schedule/form',
        builder: (_, s) =>
            CourseFormScreen(id: int.tryParse(s.uri.queryParameters['id'] ?? '')),
      ),
      GoRoute(path: '/schedule/import', builder: (_, __) => const ImportScreen()),
      GoRoute(
        path: '/schedule/import/review',
        builder: (_, s) => ImportReviewScreen(result: s.extra as ImportResult),
      ),

      // Lima halaman utama dengan Bottom Navigation (state tiap tab tetap terjaga).
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tasks', builder: (_, __) => const TaskListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
}
