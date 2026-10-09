import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/schedule_parser.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../widgets/app_button.dart';

/// Meninjau & mengoreksi hasil OCR sebelum disimpan.
class ImportReviewScreen extends StatefulWidget {
  const ImportReviewScreen({super.key, required this.result});
  final ImportResult result;

  @override
  State<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends State<ImportReviewScreen> {
  List<ParsedCourse> get _items => widget.result.drafts;
  bool _saving = false;

  int get _selectedCount => _items.where((d) => d.selected).length;

  Future<void> _edit(int i) async {
    final d = _items[i];
    final c = d.course;
    final name = TextEditingController(text: c.name);
    final room = TextEditingController(text: c.room);
    var day = c.day;
    var start = DateHelper.strToTime(c.start);
    var end = DateHelper.strToTime(c.end);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Ubah Mata Kuliah'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nama mata kuliah')),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: day,
                  decoration: const InputDecoration(labelText: 'Hari'),
                  items: [
                    for (var k = 1; k <= 7; k++)
                      DropdownMenuItem(value: k, child: Text(DateHelper.dayName(k))),
                  ],
                  onChanged: (v) => setS(() => day = v ?? day),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: start);
                          if (t != null) setS(() => start = t);
                        },
                        child: Text('Mulai ${DateHelper.timeToStr(start)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: end);
                          if (t != null) setS(() => end = t);
                        },
                        child: Text('Selesai ${DateHelper.timeToStr(end)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: room,
                    decoration: const InputDecoration(labelText: 'Ruang')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
          ],
        ),
      ),
    );

    if (ok == true && name.text.trim().isNotEmpty) {
      setState(() {
        d.course = c.copyWith(
          name: name.text.trim(),
          day: day,
          start: DateHelper.timeToStr(start),
          end: DateHelper.timeToStr(end),
          room: room.text.trim(),
        );
        d.warning = null;
      });
    }
    name.dispose();
    room.dispose();
  }

  Future<void> _save() async {
    final userId = context.read<AuthProvider>().user!.id;
    final chosen = _items
        .where((d) => d.selected)
        .map((d) => d.course.copyWith(userId: userId))
        .toList();
    if (chosen.isEmpty) return;
    setState(() => _saving = true);
    await context.read<ScheduleProvider>().addAll(chosen);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${chosen.length} mata kuliah disimpan')));
    context.go('/schedule');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tinjau Hasil Pindai')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppButton(
            label: 'Simpan $_selectedCount Mata Kuliah',
            loading: _saving,
            onPressed: _selectedCount == 0 ? null : _save,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.file(File(widget.result.imagePath),
                      height: 120, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Foto sumber',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_items.length} mata kuliah terdeteksi',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Periksa dan perbaiki sebelum menyimpan',
                      style: TextStyle(color: theme.hintColor, fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final d = _items[i];
                final c = d.course;
                final warn = d.warning != null;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: warn ? const Color(0xFFFFFBEB) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: warn ? const Color(0xFFF59E0B) : theme.dividerColor,
                        width: warn ? 1.5 : 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: d.selected,
                          onChanged: (v) => setState(() => d.selected = v ?? false),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: warn ? Colors.black87 : null)),
                              const SizedBox(height: 2),
                              Text(
                                '${DateHelper.dayName(c.day)} · ${c.start}–${c.end}'
                                '${c.room.isEmpty ? '' : ' · ${c.room}'}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: warn ? const Color(0xFFB45309) : theme.hintColor),
                              ),
                              if (warn)
                                Text(d.warning!,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309))),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _edit(i),
                          child: const Text('Ubah',
                              style: TextStyle(color: AppTheme.primary)),
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
