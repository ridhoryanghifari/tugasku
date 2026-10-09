import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Penyimpanan lokal SQLite (singleton).
class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'tugasku.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE courses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            day INTEGER NOT NULL,
            start TEXT NOT NULL,
            "end" TEXT NOT NULL,
            room TEXT,
            lecturer TEXT,
            reminder INTEGER NOT NULL DEFAULT 1
          )''');
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            course_name TEXT,
            due TEXT NOT NULL,
            type TEXT NOT NULL,
            priority INTEGER NOT NULL,
            reminder INTEGER NOT NULL DEFAULT 1,
            done INTEGER NOT NULL DEFAULT 0,
            done_at TEXT
          )''');
      },
    );
  }
}
