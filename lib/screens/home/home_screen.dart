import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final schedule = context.watch<ScheduleProvider>();

    final today = tasks.todayTasks;
    final done = today.where((t) => t.done).length;
    final upcoming = tasks.upcoming(3);
    final todayCourses = schedule.today;
    final firstName = (auth.user?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: AppBar(title: Text('Halo, $firstName!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/form'),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          _ProgressCard(done: done, total: today.length),
          const SizedBox(height: 20),
          const _SectionTitle('Deadline Terdekat'),
          if (upcoming.isEmpty)
            const _EmptyHint('Belum ada tugas. Tekan + untuk menambah.')
          else
            for (final t in upcoming)
              TaskCard(task: t, onTap: () => context.push('/tasks/form?id=${t.id}')),
          const SizedBox(height: 12),
          const _SectionTitle('Kuliah Hari Ini'),
          if (todayCourses.isEmpty)
            const _EmptyHint('Tidak ada kuliah hari ini.')
          else
            for (final c in todayCourses) _CourseTile(course: c),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: CircleAvatar(
                radius: 56, backgroundColor: Colors.white.withOpacity(0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progres Hari Ini',
                    style: TextStyle(color: Color(0xFFC7D2FE))),
                const SizedBox(height: 6),
                Text(
                  total == 0 ? 'Tidak ada tenggat hari ini' : '$done dari $total tugas selesai',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF818CF8),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: TextStyle(color: Theme.of(context).hintColor)),
      );
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined, color: AppTheme.primary),
        title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${course.start} – ${course.end}${course.room.isEmpty ? '' : ' · ${course.room}'}'),
      ),
    );
  }
}
