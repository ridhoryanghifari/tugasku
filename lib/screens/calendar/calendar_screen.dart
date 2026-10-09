import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/task.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_card.dart';

/// Kalender bulanan: titik berwarna menandai tugas, kuis, UTS, dan UAS.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cal = context.watch<CalendarProvider>();
    final tasks = context.watch<TaskProvider>();
    final events = cal.eventsOf(cal.selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Akademik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah agenda',
            onPressed: () {
              final d = DateFormat('yyyy-MM-dd').format(cal.selectedDay);
              context.push('/tasks/form?date=$d');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: TableCalendar<Task>(
              locale: 'id_ID',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: cal.focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
              selectedDayPredicate: (d) => isSameDay(d, cal.selectedDay),
              eventLoader: (d) => tasks.tasksOn(d),
              onDaySelected: cal.select,
              onPageChanged: cal.setFocused,
              calendarBuilders: CalendarBuilders<Task>(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final types = events.map((e) => e.type).toSet().toList();
                  return Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final t in types)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration:
                                BoxDecoration(color: t.color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const _Legend(),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Agenda ${DateFormat('d MMMM y', 'id_ID').format(cal.selectedDay)}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text('Tidak ada agenda pada tanggal ini',
                        style: TextStyle(color: Theme.of(context).hintColor)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final t in events)
                        TaskCard(
                          task: t,
                          onTap: () => context.push('/tasks/form?id=${t.id}'),
                          onToggle: (_) => tasks.toggleDone(t),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final t in TaskType.values)
            Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: t.color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(t.label, style: const TextStyle(fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }
}
