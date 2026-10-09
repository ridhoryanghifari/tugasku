import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);
  final AuthRepository _repo;

  AppUser? user;
  bool initialized = false;
  bool loading = false;
  String? error;

  bool get isLoggedIn => user != null;

  /// Memuat sesi login yang tersimpan (ditampilkan di Splash minimal ±1,2 detik).
  Future<void> init() async {
    user = await _repo.currentUser();
    await Future.delayed(const Duration(milliseconds: 1200));
    initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final u = await _repo.login(email, password);
      if (u == null) {
        error = 'Email atau kata sandi salah';
      } else {
        user = u;
      }
    } catch (e) {
      error = 'Terjadi kesalahan: $e';
    }
    loading = false;
    notifyListeners();
    return user != null;
  }

  Future<bool> register(String name, String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await _repo.register(name, email, password);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    loading = false;
    notifyListeners();
    return user != null;
  }

  void clearError() {
    error = null;
  }

  Future<void> logout() async {
    await _repo.logout();
    await NotificationService.cancelAll();
    user = null;
    notifyListeners();
  }
}
