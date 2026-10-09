class Validators {
  static String? required(String? v, [String label = 'Kolom']) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  static String? email(String? v) {
    final r = required(v, 'Email');
    if (r != null) return r;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim());
    return ok ? null : 'Format email tidak valid';
  }

  static String? password(String? v) =>
      (v == null || v.length < 6) ? 'Kata sandi minimal 6 karakter' : null;
}
