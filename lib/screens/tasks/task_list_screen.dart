import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _query = '';
  TaskFilter _filter = TaskFilter.semua;

  static const _labels = {
    TaskFilter.semua: 'Semua',
    TaskFilter.aktif: 'Aktif',
    TaskFilter.selesai: 'Selesai',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final list = provider.filter(query: _query, filter: _filter);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/form'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari tugas...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final f in TaskFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_labels[f]!),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('Tidak ada tugas',
                        style: TextStyle(color: Theme.of(context).hintColor)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final t = list[i];
                      return Dismissible(
                        key: ValueKey('task-${t.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          provider.delete(t.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('"${t.title}" dihapus')));
                        },
                        child: TaskCard(
                          task: t,
                          onTap: () => context.push('/tasks/form?id=${t.id}'),
                          onToggle: (_) => provider.toggleDone(t),
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
