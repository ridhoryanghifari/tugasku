import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR di perangkat (offline) memakai Google ML Kit.
class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Mengembalikan teks hasil pindai per baris, berurutan dari atas ke bawah.
  Future<List<String>> readLines(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    final lines = <TextLine>[
      for (final block in result.blocks) ...block.lines,
    ];
    // Urutkan berdasarkan posisi vertikal agar baris yang sejajar berdekatan.
    lines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));
    return lines.map((l) => l.text).toList();
  }

  void dispose() {
    // Di desktop plugin ML Kit tidak tersedia; abaikan error saat menutup.
    _recognizer.close().catchError((_) {});
  }
}
