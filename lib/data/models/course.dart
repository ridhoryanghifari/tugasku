class Course {
  const Course({
    this.id,
    required this.userId,
    required this.name,
    required this.day,
    required this.start,
    required this.end,
    this.room = '',
    this.lecturer = '',
    this.reminder = true,
  });

  final int? id;
  final int userId;
  final String name;
  final int day; // 1 = Senin ... 7 = Minggu
  final String start; // "HH:mm"
  final String end; // "HH:mm"
  final String room;
  final String lecturer;
  final bool reminder;

  Course copyWith({
    int? id, int? userId, String? name, int? day, String? start, String? end,
    String? room, String? lecturer, bool? reminder,
  }) =>
      Course(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        day: day ?? this.day,
        start: start ?? this.start,
        end: end ?? this.end,
        room: room ?? this.room,
        lecturer: lecturer ?? this.lecturer,
        reminder: reminder ?? this.reminder,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'day': day,
        'start': start,
        'end': end,
        'room': room,
        'lecturer': lecturer,
        'reminder': reminder ? 1 : 0,
      };

  factory Course.fromMap(Map<String, Object?> m) => Course(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        name: m['name'] as String,
        day: m['day'] as int,
        start: m['start'] as String,
        end: m['end'] as String,
        room: (m['room'] as String?) ?? '',
        lecturer: (m['lecturer'] as String?) ?? '',
        reminder: (m['reminder'] as int) == 1,
      );
}
