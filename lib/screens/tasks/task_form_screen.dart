import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../data/models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/app_button.dart';

/// Form tambah / ubah agenda (Tugas, Kuis, UTS, UAS).
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.id, this.initialDate});
  final int? id;
  final DateTime? initialDate;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  Task? _editing;
  String _course = '';
  late DateTime _due;
  TaskType _type = TaskType.tugas;
  TaskPriority _priority = TaskPriority.sedang;
  bool _reminder = true;

  @override
  void initState() {
    super.initState();
    final id = widget.id;
    if (id != null) _editing = context.read<TaskProvider>().byId(id);
    final e = _editing;
    if (e != null) {
      _title.text = e.title;
      _course = e.courseName;
      _due = e.due;
      _type = e.type;
      _priority = e.priority;
      _reminder = e.reminder;
    } else {
      final base = widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
      _due = DateTime(base.year, base.month, base.day, 23, 59);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_due));
    if (t == null) return;
    setState(() => _due = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final userId = context.read<AuthProvider>().user!.id;
    final provider = context.read<TaskProvider>();
    final task = Task(
      id: _editing?.id,
      userId: userId,
      title: _title.text.trim(),
      courseName: _course,
      due: _due,
      type: _type,
      priority: _priority,
      reminder: _reminder,
      done: _editing?.done ?? false,
      doneAt: _editing?.doneAt,
    );
    if (_editing == null) {
      await provider.add(task);
    } else {
      await provider.update(task);
    }
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus agenda?'),
        content: Text('"${_editing!.title}" akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<TaskProvider>().delete(_editing!.id!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseNames = context.watch<ScheduleProvider>().names;
    final items = <String>{'', ...courseNames, if (_course.isNotEmpty) _course}.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'Tambah Agenda' : 'Ubah Agenda'),
        actions: [
          if (_editing != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Judul Agenda', hintText: 'Contoh: UTS Basis Data'),
                validator: (v) => Validators.required(v, 'Judul'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _course,
                decoration: InputDecoration(
                  labelText: 'Mata Kuliah',
                  helperText: courseNames.isEmpty
                      ? 'Tambahkan mata kuliah di menu Jadwal agar muncul di sini'
                      : null,
                ),
                items: [
                  for (final n in items)
                    DropdownMenuItem(
                        value: n, child: Text(n.isEmpty ? '— Tanpa mata kuliah —' : n)),
                ],
                onChanged: (v) => setState(() => _course = v ?? ''),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDue,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal & Jam',
                    suffixIcon: Icon(Icons.event),
                  ),
                  child: Text(DateFormat('EEEE, d MMMM y · HH:mm', 'id_ID').format(_due)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Jenis', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in TaskType.values)
                    ChoiceChip(
                      label: Text(t.label),
                      selected: _type == t,
                      selectedColor: t.color.withOpacity(0.25),
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final p in TaskPriority.values)
                    ChoiceChip(
                      label: Text(p.label),
                      selected: _priority == p,
                      selectedColor: p.color.withOpacity(0.25),
                      onSelected: (_) => setState(() => _priority = p),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pengingat', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Notifikasi 1 hari sebelum tenggat'),
                value: _reminder,
                onChanged: (v) => setState(() => _reminder = v),
              ),
              const SizedBox(height: 16),
              AppButton(label: 'Simpan Agenda', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
