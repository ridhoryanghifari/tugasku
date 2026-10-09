import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../providers/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _day = DateTime.now().weekday; // 1 = Senin ... 7 = Minggu

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final list = provider.coursesOn(_day);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/schedule/import'),
            icon: const Icon(Icons.document_scanner_outlined, color: Colors.white),
            label: const Text('Impor', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah mata kuliah',
            onPressed: () => context.push('/schedule/form'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 76,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: 7,
              itemBuilder: (context, i) {
                final d = i + 1;
                final selected = d == _day;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppTheme.primary,
                    label: SizedBox(
                      width: 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(DateHelper.daysShort[i],
                              style: TextStyle(
                                  color: selected ? Colors.white : null,
                                  fontWeight: FontWeight.bold)),
                          Text('${provider.coursesOn(d).length} kuliah',
                              style: TextStyle(
                                  fontSize: 10, color: selected ? Colors.white70 : null)),
                        ],
                      ),
                    ),
                    onSelected: (_) => setState(() => _day = d),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available, size: 56, color: theme.hintColor),
                        const SizedBox(height: 8),
                        Text('Tidak ada kuliah hari ${DateHelper.dayName(_day)}',
                            style: TextStyle(color: theme.hintColor)),
                        const SizedBox(height: 4),
                        Text('Tambah manual (+) atau impor dari foto',
                            style: TextStyle(color: theme.hintColor, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return Dismissible(
                        key: ValueKey('course-${c.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => provider.delete(c.id!),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text(c.start,
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Column(
                                children: [
                                  const CircleAvatar(
                                      radius: 5, backgroundColor: AppTheme.primary),
                                  Expanded(
                                      child: Container(width: 2, color: theme.dividerColor)),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  color: AppTheme.primary.withOpacity(0.08),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => context.push('/schedule/form?id=${c.id}'),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 15)),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${c.start} – ${c.end}'
                                            '${c.room.isEmpty ? '' : ' · ${c.room}'}'
                                            '${c.lecturer.isEmpty ? '' : ' · ${c.lecturer}'}',
                                            style: TextStyle(
                                                color: theme.hintColor, fontSize: 12),
                                          ),
                                          if (c.reminder)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text('Pengingat 15 menit sebelum',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: AppTheme.primary)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
