import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_helper.dart';
import '../../core/utils/validators.dart';
import '../../data/models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../widgets/app_button.dart';

/// Form tambah / ubah mata kuliah (input manual).
class CourseFormScreen extends StatefulWidget {
  const CourseFormScreen({super.key, this.id});
  final int? id;

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _room = TextEditingController();
  final _lecturer = TextEditingController();
  Course? _editing;
  int _day = DateTime.now().weekday;
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);
  bool _reminder = true;

  @override
  void initState() {
    super.initState();
    final id = widget.id;
    if (id != null) _editing = context.read<ScheduleProvider>().byId(id);
    final c = _editing;
    if (c != null) {
      _name.text = c.name;
      _room.text = c.room;
      _lecturer.text = c.lecturer;
      _day = c.day;
      _start = DateHelper.strToTime(c.start);
      _end = DateHelper.strToTime(c.end);
      _reminder = c.reminder;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _room.dispose();
    _lecturer.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isStart) async {
    final t = await showTimePicker(
        context: context, initialTime: isStart ? _start : _end);
    if (t == null) return;
    setState(() => isStart ? _start = t : _end = t);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (DateHelper.toMinutes(_end) <= DateHelper.toMinutes(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jam selesai harus setelah jam mulai')));
      return;
    }
    final provider = context.read<ScheduleProvider>();
    final course = Course(
      id: _editing?.id,
      userId: context.read<AuthProvider>().user!.id,
      name: _name.text.trim(),
      day: _day,
      start: DateHelper.timeToStr(_start),
      end: DateHelper.timeToStr(_end),
      room: _room.text.trim(),
      lecturer: _lecturer.text.trim(),
      reminder: _reminder,
    );
    if (_editing == null) {
      await provider.add(course);
    } else {
      await provider.update(course);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_editing == null ? 'Tambah Mata Kuliah' : 'Ubah Mata Kuliah')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Nama Mata Kuliah', hintText: 'Contoh: Pemrograman Mobile'),
                validator: (v) => Validators.required(v, 'Nama mata kuliah'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _day,
                decoration: const InputDecoration(labelText: 'Hari'),
                items: [
                  for (var d = 1; d <= 7; d++)
                    DropdownMenuItem(value: d, child: Text(DateHelper.dayName(d))),
                ],
                onChanged: (v) => setState(() => _day = v ?? _day),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pick(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Jam Mulai', suffixIcon: Icon(Icons.access_time)),
                        child: Text(DateHelper.timeToStr(_start)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pick(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Jam Selesai', suffixIcon: Icon(Icons.access_time)),
                        child: Text(DateHelper.timeToStr(_end)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _room,
                decoration: const InputDecoration(labelText: 'Ruang', hintText: 'Contoh: Lab 2'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lecturer,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Dosen'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pengingat', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('15 menit sebelum kuliah dimulai (setiap minggu)'),
                value: _reminder,
                onChanged: (v) => setState(() => _reminder = v),
              ),
              const SizedBox(height: 16),
              AppButton(label: 'Simpan Mata Kuliah', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
