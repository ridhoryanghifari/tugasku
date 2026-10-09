import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/schedule_parser.dart';
import '../../services/ocr_service.dart';
import '../widgets/app_button.dart';

/// Memilih foto KRS / jadwal dosen, lalu membacanya dengan OCR.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _picker = ImagePicker();
  final _ocr = OcrService();
  String? _path;
  bool _busy = false;

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 90);
      if (x != null) setState(() => _path = x.path);
    } catch (e) {
      _msg('Tidak dapat mengambil gambar: $e');
    }
  }

  Future<void> _scan() async {
    final path = _path;
    if (path == null) return;
    setState(() => _busy = true);
    try {
      final lines = await _ocr.readLines(path);
      final drafts = ScheduleParser.parse(lines);
      if (!mounted) return;
      if (drafts.isEmpty) {
        _msg('Jadwal tidak terbaca. Coba foto yang lebih jelas atau isi manual.');
      } else {
        context.push('/schedule/import/review', extra: ImportResult(path, drafts));
      }
    } catch (e) {
      if (mounted) _msg('Gagal membaca foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Impor Jadwal')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Impor jadwal dari foto (kamera + OCR) hanya tersedia di Android/iOS.\n'
              'Di browser, tambahkan mata kuliah secara manual lewat tombol +.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Impor Jadwal')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Foto KRS atau jadwal dari dosen',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Aplikasi membaca teks pada foto secara otomatis',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor, fontSize: 12)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _path == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_camera_outlined,
                              size: 56, color: AppTheme.primary),
                          const SizedBox(height: 8),
                          const Text('Belum ada foto',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          Text('Ambil foto atau pilih dari galeri',
                              style: TextStyle(color: theme.hintColor, fontSize: 12)),
                        ],
                      )
                    : Image.file(File(_path!), fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Ambil Foto',
              icon: Icons.photo_camera,
              onPressed: () => _pick(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Pilih dari Galeri',
              icon: Icons.photo_library_outlined,
              outlined: true,
              onPressed: () => _pick(ImageSource.gallery),
            ),
            if (_path != null) ...[
              const SizedBox(height: 10),
              AppButton(
                label: 'Pindai Jadwal',
                icon: Icons.document_scanner,
                loading: _busy,
                onPressed: _scan,
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE047)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tips agar hasil akurat',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF854D0E))),
                  SizedBox(height: 6),
                  Text('•  Foto dalam cahaya terang',
                      style: TextStyle(color: Color(0xFF854D0E), fontSize: 12)),
                  Text('•  Posisi lurus, tidak miring',
                      style: TextStyle(color: Color(0xFF854D0E), fontSize: 12)),
                  Text('•  Seluruh tabel masuk dalam foto',
                      style: TextStyle(color: Color(0xFF854D0E), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
