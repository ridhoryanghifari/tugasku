import 'package:flutter_test/flutter_test.dart';
import 'package:tugasku/core/utils/schedule_parser.dart';

void main() {
  test('ScheduleParser membaca hari, jam, ruang, dan nama mata kuliah', () {
    final result = ScheduleParser.parse([
      'Senin',
      '08.00-10.30 Pemrograman Mobile Lab 2',
      'Selasa 13.00 – 15.00 Jaringan Komputer R.204',
      'Rabu 15.3? Metodologi Penelitian R110',
    ]);

    expect(result.length, 3);

    final a = result[0].course;
    expect(a.name, 'Pemrograman Mobile');
    expect(a.day, 1);
    expect(a.start, '08:00');
    expect(a.end, '10:30');
    expect(a.room, 'Lab 2');
    expect(result[0].warning, isNull);

    final b = result[1].course;
    expect(b.name, 'Jaringan Komputer');
    expect(b.day, 2);
    expect(b.room, 'R.204');

    // Jam tidak terbaca -> ditandai agar diperiksa pengguna.
    expect(result[2].course.day, 3);
    expect(result[2].warning, isNotNull);
  });
}
