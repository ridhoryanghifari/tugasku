import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // Setelah logout, redirect GoRouter otomatis ke /login.
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final tasks = context.watch<TaskProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final week = tasks.doneThisWeek();
    final maxY = (week.reduce((a, b) => a > b ? a : b) + 2).toDouble();
    final today = DateTime.now().weekday - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik & Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primary.withOpacity(0.12),
                child: Text(
                  (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(user?.email ?? '',
                        style: TextStyle(color: theme.hintColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(value: '${tasks.doneCount}', label: 'Selesai'),
              const SizedBox(width: 10),
              _StatBox(value: '${tasks.activeCount}', label: 'Aktif'),
              const SizedBox(width: 10),
              _StatBox(value: '${tasks.upcomingExams}', label: 'Ujian'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Tugas Selesai Minggu Ini',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor),
            ),
            child: SizedBox(
              height: 190,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) => Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(DateHelper.daysShort[v.toInt()],
                                style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < 7; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: week[i].toDouble(),
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                            color: i == today
                                ? AppTheme.primary
                                : AppTheme.primary.withOpacity(0.35),
                          ),
                        ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: theme.dividerColor)),
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Pengaturan Notifikasi'),
            subtitle: const Text('Izinkan notifikasi pengingat'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final ok = await NotificationService.requestPermission();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Notifikasi diizinkan'
                      : 'Izin notifikasi ditolak. Aktifkan di pengaturan perangkat.')));
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: theme.dividerColor)),
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode Gelap'),
            value: settings.isDark(context),
            onChanged: settings.setDark,
          ),
          const SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: theme.dividerColor)),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
            ],
          ),
        ),
      );
}
