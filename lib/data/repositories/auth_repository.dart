import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../sources/local_db.dart';

class AuthRepository {
  static const _sessionKey = 'session_user_id';

  String _hash(String email, String password) =>
      sha256.convert(utf8.encode('${email.toLowerCase()}:$password')).toString();

  Future<AppUser> register(String name, String email, String password) async {
    final db = await LocalDb.instance.db;
    final e = email.trim().toLowerCase();
    final exist = await db.query('users', where: 'email = ?', whereArgs: [e]);
    if (exist.isNotEmpty) throw Exception('Email sudah terdaftar');
    final id = await db.insert('users', {
      'name': name.trim(),
      'email': e,
      'password_hash': _hash(e, password),
    });
    await _saveSession(id);
    return AppUser(id: id, name: name.trim(), email: e);
  }

  Future<AppUser?> login(String email, String password) async {
    final db = await LocalDb.instance.db;
    final e = email.trim().toLowerCase();
    final rows = await db.query('users',
        where: 'email = ? AND password_hash = ?', whereArgs: [e, _hash(e, password)]);
    if (rows.isEmpty) return null;
    final id = rows.first['id'] as int;
    await _saveSession(id);
    return AppUser(id: id, name: rows.first['name'] as String, email: e);
  }

  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_sessionKey);
    if (id == null) return null;
    final db = await LocalDb.instance.db;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AppUser(
        id: id, name: rows.first['name'] as String, email: rows.first['email'] as String);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _saveSession(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, id);
  }
}
