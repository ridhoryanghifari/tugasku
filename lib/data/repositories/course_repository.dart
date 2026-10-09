import '../models/course.dart';
import '../sources/local_db.dart';

class CourseRepository {
  Future<List<Course>> getAll(int userId) async {
    final db = await LocalDb.instance.db;
    final rows = await db.query('courses',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'day ASC, start ASC');
    return rows.map(Course.fromMap).toList();
  }

  Future<int> insert(Course c) async {
    final db = await LocalDb.instance.db;
    return db.insert('courses', c.toMap()..remove('id'));
  }

  Future<void> update(Course c) async {
    final db = await LocalDb.instance.db;
    await db.update('courses', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<void> delete(int id) async {
    final db = await LocalDb.instance.db;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }
}
