import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Layar pembuka. Perpindahan ke Login/Beranda ditangani redirect GoRouter
/// setelah AuthProvider.init() selesai memeriksa sesi login.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 56,
              backgroundColor: Colors.white,
              child: Icon(Icons.check_rounded, size: 72, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(AppConstants.appName,
                style: TextStyle(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Atur tugas, raih prestasi',
                style: TextStyle(color: Color(0xFFC7D2FE))),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
