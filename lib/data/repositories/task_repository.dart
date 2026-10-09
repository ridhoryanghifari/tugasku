import '../models/task.dart';
import '../sources/local_db.dart';

class TaskRepository {
  Future<List<Task>> getAll(int userId) async {
    final db = await LocalDb.instance.db;
    final rows =
        await db.query('tasks', where: 'user_id = ?', whereArgs: [userId], orderBy: 'due ASC');
    return rows.map(Task.fromMap).toList();
  }

  Future<int> insert(Task t) async {
    final db = await LocalDb.instance.db;
    return db.insert('tasks', t.toMap()..remove('id'));
  }

  Future<void> update(Task t) async {
    final db = await LocalDb.instance.db;
    await db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> delete(int id) async {
    final db = await LocalDb.instance.db;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
