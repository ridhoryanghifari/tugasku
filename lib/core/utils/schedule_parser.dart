import '../../data/models/course.dart';

/// Satu mata kuliah hasil pembacaan OCR yang masih bisa dikoreksi pengguna.
class ParsedCourse {
  ParsedCourse({required this.course, this.warning, this.selected = true});
  Course course;
  String? warning;
  bool selected;
}

class ImportResult {
  const ImportResult(this.imagePath, this.drafts);
  final String imagePath;
  final List<ParsedCourse> drafts;
}

/// Mengubah baris-baris teks hasil OCR menjadi daftar mata kuliah.
class ScheduleParser {
  static final _dayRe = RegExp(
      r"\b(senin|selasa|rabu|kamis|jum'?at|sabtu|minggu|ahad)\b",
      caseSensitive: false);
  static const _dayAbbr = {
    'sen': 1, 'sel': 2, 'rab': 3, 'kam': 4, 'jum': 5, 'sab': 6, 'min': 7,
  };
  static final _rangeRe = RegExp(
      r'(\d{1,2})\s*[.:]\s*(\d{2})\s*(?:-|–|—|s/d|s\.d\.?|sd|sampai)\s*(\d{1,2})\s*[.:]\s*(\d{2})',
      caseSensitive: false);
  static final _singleRe = RegExp(r'\b(\d{1,2})\s*[.:]\s*(\d{2})\b');
  static final _roomRe = RegExp(
      r'\b(?:ruang(?:an)?|lab(?:oratorium)?|gedung|gd|r)\.?\s*[A-Za-z]?\d{1,4}[A-Za-z]?\b',
      caseSensitive: false);
  static final _codeRe = RegExp(r'\b[A-Z]{2,4}\s?\d{3,5}\b');
  static final _sksRe = RegExp(r'\b\d\s*sks\b', caseSensitive: false);

  static int? _dayOf(String text) {
    final m = _dayRe.firstMatch(text);
    if (m != null) {
      final w = m.group(1)!.toLowerCase().replaceAll("'", '');
      switch (w) {
        case 'senin': return 1;
        case 'selasa': return 2;
        case 'rabu': return 3;
        case 'kamis': return 4;
        case 'jumat': return 5;
        case 'sabtu': return 6;
        default: return 7; // minggu / ahad
      }
    }
    final first = text.trim().split(RegExp(r'\s+')).first.toLowerCase();
    return _dayAbbr[first.replaceAll(RegExp(r'[^a-z]'), '')];
  }

  static String _removeDay(String text) {
    var t = text.replaceAll(_dayRe, ' ');
    final parts = t.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty && _dayAbbr.containsKey(parts.first.toLowerCase())) {
      t = parts.skip(1).join(' ');
    }
    return t;
  }

  static String? _hm(String h, String m) {
    final hh = int.tryParse(h), mm = int.tryParse(m);
    if (hh == null || mm == null || hh > 23 || mm > 59) return null;
    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
  }

  static String _addMinutes(String hm, int add) {
    final p = hm.split(':');
    final total = (int.parse(p[0]) * 60 + int.parse(p[1]) + add) % (24 * 60);
    return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  }

  static String _tidy(String s) {
    var t = s.replaceAll(RegExp(r'[|_\[\]{}<>;:"“”]'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    t = t.replaceFirst(RegExp(r'^[\d\W]+'), '').trim(); // buang angka/tanda di awal
    return t.replaceFirst(RegExp(r'[\s\-–,.]+$'), '');
  }

  static (String?, String) _splitRoom(String text) {
    final r = _roomRe.firstMatch(text);
    if (r == null) return (null, text);
    return (r.group(0)!.trim(), text.replaceRange(r.start, r.end, ' '));
  }

  static List<ParsedCourse> parse(List<String> rawLines) {
    final lines = rawLines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final out = <ParsedCourse>[];
    int? currentDay;

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      final dayHere = _dayOf(line);
      if (dayHere != null) {
        currentDay = dayHere;
        line = _removeDay(line);
      }

      String? start, end, warning;
      final range = _rangeRe.firstMatch(line);
      if (range != null) {
        start = _hm(range.group(1)!, range.group(2)!);
        end = _hm(range.group(3)!, range.group(4)!);
        line = line.replaceRange(range.start, range.end, ' ');
      }
      if (start == null || end == null) {
        final single = _singleRe.firstMatch(line);
        final s = single == null ? null : _hm(single.group(1)!, single.group(2)!);
        if (s != null) {
          start = s;
          end = _addMinutes(s, 100);
          warning = 'Jam selesai diperkirakan, mohon periksa';
          line = line.replaceRange(single!.start, single.end, ' ');
        } else {
          start = null;
          end = null;
        }
      }

      var (room, rest) = _splitRoom(line);
      rest = rest.replaceAll(_codeRe, ' ').replaceAll(_sksRe, ' ');
      var name = _tidy(rest);

      if (start == null) {
        // Baris berisi hari + nama tetapi jam tidak terbaca: tampilkan dengan peringatan.
        if (dayHere != null && name.length >= 3) {
          start = '08:00';
          end = '09:40';
          warning = 'Jam tidak terbaca, mohon periksa';
        } else {
          continue;
        }
      }

      // Nama mungkin berada di baris berikutnya.
      if (name.length < 3 && i + 1 < lines.length) {
        final next = lines[i + 1];
        if (_rangeRe.firstMatch(next) == null && _dayOf(next) == null) {
          final (r2, rest2) = _splitRoom(next);
          room ??= r2;
          name = _tidy(rest2.replaceAll(_codeRe, ' ').replaceAll(_sksRe, ' '));
          i++;
        }
      }
      if (name.length < 3) continue;

      if (currentDay == null) warning ??= 'Hari tidak terbaca, mohon periksa';
      out.add(ParsedCourse(
        course: Course(
          userId: 0,
          name: name,
          day: currentDay ?? 1,
          start: start,
          end: end!,
          room: room ?? '',
        ),
        warning: warning,
      ));
    }
    return out;
  }
}
