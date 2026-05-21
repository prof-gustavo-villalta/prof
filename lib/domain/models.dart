enum AttendanceStatus {
  absent,
  present,
  late,
  justified;

  String get label {
    switch (this) {
      case AttendanceStatus.absent:
        return 'Ausente';
      case AttendanceStatus.present:
        return 'Presente';
      case AttendanceStatus.late:
        return 'Atraso';
      case AttendanceStatus.justified:
        return 'Justificado';
    }
  }
}

class Term {
  const Term({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;

  Term copyWith({String? name, DateTime? startDate, DateTime? endDate}) => Term(
    id: id,
    name: name ?? this.name,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory Term.fromJson(Map<String, Object?> json) => Term(
    id: json['id']! as String,
    name: json['name']! as String,
    startDate: _dateOrNull(json['startDate']),
    endDate: _dateOrNull(json['endDate']),
  );
}

class ClassGroup {
  const ClassGroup({
    required this.id,
    required this.name,
    required this.termId,
  });

  final String id;
  final String name;
  final String termId;

  ClassGroup copyWith({String? name}) =>
      ClassGroup(id: id, name: name ?? this.name, termId: termId);

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'termId': termId};

  factory ClassGroup.fromJson(Map<String, Object?> json) => ClassGroup(
    id: json['id']! as String,
    name: json['name']! as String,
    termId: json['termId']! as String,
  );
}

class Discipline {
  const Discipline({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'name': name};

  factory Discipline.fromJson(Map<String, Object?> json) =>
      Discipline(id: json['id']! as String, name: json['name']! as String);
}

class Student {
  const Student({
    required this.id,
    required this.classGroupId,
    required this.name,
    this.photoBase64,
  });

  final String id;
  final String classGroupId;
  final String name;
  final String? photoBase64;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  Student copyWith({String? photoBase64}) => Student(
    id: id,
    classGroupId: classGroupId,
    name: name,
    photoBase64: photoBase64 ?? this.photoBase64,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'classGroupId': classGroupId,
    'name': name,
    'photoBase64': photoBase64,
  };

  factory Student.fromJson(Map<String, Object?> json) => Student(
    id: json['id']! as String,
    classGroupId: json['classGroupId']! as String,
    name: json['name']! as String,
    photoBase64: json['photoBase64'] as String?,
  );
}

class WeeklyClass {
  const WeeklyClass({
    required this.id,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.classGroupId,
    required this.disciplineId,
  });

  final String id;
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final String classGroupId;
  final String disciplineId;

  WeeklyClass copyWith({
    int? weekday,
    int? startMinutes,
    int? endMinutes,
    String? classGroupId,
    String? disciplineId,
  }) => WeeklyClass(
    id: id,
    weekday: weekday ?? this.weekday,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    classGroupId: classGroupId ?? this.classGroupId,
    disciplineId: disciplineId ?? this.disciplineId,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'weekday': weekday,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'classGroupId': classGroupId,
    'disciplineId': disciplineId,
  };

  factory WeeklyClass.fromJson(Map<String, Object?> json) => WeeklyClass(
    id: json['id']! as String,
    weekday: json['weekday']! as int,
    startMinutes: json['startMinutes']! as int,
    endMinutes: json['endMinutes']! as int,
    classGroupId: json['classGroupId']! as String,
    disciplineId: json['disciplineId']! as String,
  );
}

class LessonOccurrence {
  const LessonOccurrence({required this.weeklyClass, required this.date});

  final WeeklyClass weeklyClass;
  final DateTime date;

  String get id => '${weeklyClass.id}|${_dateKey(date)}';

  DateTime get start => DateTime(
    date.year,
    date.month,
    date.day,
    weeklyClass.startMinutes ~/ 60,
    weeklyClass.startMinutes % 60,
  );

  DateTime get end => DateTime(
    date.year,
    date.month,
    date.day,
    weeklyClass.endMinutes ~/ 60,
    weeklyClass.endMinutes % 60,
  );
}

class Attendance {
  const Attendance({
    required this.id,
    required this.lessonId,
    required this.weeklyClassId,
    required this.date,
    required this.isClosed,
    required this.statusByStudentId,
  });

  final String id;
  final String lessonId;
  final String weeklyClassId;
  final DateTime date;
  final bool isClosed;
  final Map<String, AttendanceStatus> statusByStudentId;

  Attendance copyWith({
    bool? isClosed,
    Map<String, AttendanceStatus>? statusByStudentId,
  }) => Attendance(
    id: id,
    lessonId: lessonId,
    weeklyClassId: weeklyClassId,
    date: date,
    isClosed: isClosed ?? this.isClosed,
    statusByStudentId: statusByStudentId ?? this.statusByStudentId,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'weeklyClassId': weeklyClassId,
    'date': date.toIso8601String(),
    'isClosed': isClosed,
    'statusByStudentId': statusByStudentId.map(
      (key, value) => MapEntry(key, value.name),
    ),
  };

  factory Attendance.fromJson(Map<String, Object?> json) => Attendance(
    id: json['id']! as String,
    lessonId: json['lessonId']! as String,
    weeklyClassId: json['weeklyClassId']! as String,
    date: DateTime.parse(json['date']! as String),
    isClosed: json['isClosed']! as bool,
    statusByStudentId: (json['statusByStudentId']! as Map<String, Object?>).map(
      (key, value) =>
          MapEntry(key, AttendanceStatus.values.byName(value! as String)),
    ),
  );
}

class CancelledLesson {
  const CancelledLesson({required this.lessonId});

  final String lessonId;

  Map<String, Object?> toJson() => {'lessonId': lessonId};

  factory CancelledLesson.fromJson(Map<String, Object?> json) =>
      CancelledLesson(lessonId: json['lessonId']! as String);
}

class ProfData {
  const ProfData({
    this.terms = const [],
    this.classGroups = const [],
    this.disciplines = const [],
    this.students = const [],
    this.weeklyClasses = const [],
    this.attendances = const [],
    this.cancelledLessons = const [],
  });

  final List<Term> terms;
  final List<ClassGroup> classGroups;
  final List<Discipline> disciplines;
  final List<Student> students;
  final List<WeeklyClass> weeklyClasses;
  final List<Attendance> attendances;
  final List<CancelledLesson> cancelledLessons;

  bool get hasMinimumSetup =>
      classGroups.isNotEmpty &&
      disciplines.isNotEmpty &&
      students.isNotEmpty &&
      weeklyClasses.isNotEmpty;

  ProfData copyWith({
    List<Term>? terms,
    List<ClassGroup>? classGroups,
    List<Discipline>? disciplines,
    List<Student>? students,
    List<WeeklyClass>? weeklyClasses,
    List<Attendance>? attendances,
    List<CancelledLesson>? cancelledLessons,
  }) => ProfData(
    terms: terms ?? this.terms,
    classGroups: classGroups ?? this.classGroups,
    disciplines: disciplines ?? this.disciplines,
    students: students ?? this.students,
    weeklyClasses: weeklyClasses ?? this.weeklyClasses,
    attendances: attendances ?? this.attendances,
    cancelledLessons: cancelledLessons ?? this.cancelledLessons,
  );

  Map<String, Object?> toJson() => {
    'terms': terms.map((item) => item.toJson()).toList(),
    'classGroups': classGroups.map((item) => item.toJson()).toList(),
    'disciplines': disciplines.map((item) => item.toJson()).toList(),
    'students': students.map((item) => item.toJson()).toList(),
    'weeklyClasses': weeklyClasses.map((item) => item.toJson()).toList(),
    'attendances': attendances.map((item) => item.toJson()).toList(),
    'cancelledLessons': cancelledLessons.map((item) => item.toJson()).toList(),
  };

  factory ProfData.fromJson(Map<String, Object?> json) => ProfData(
    terms: _list(json['terms'], Term.fromJson),
    classGroups: _list(json['classGroups'], ClassGroup.fromJson),
    disciplines: _list(json['disciplines'], Discipline.fromJson),
    students: _list(json['students'], Student.fromJson),
    weeklyClasses: _list(json['weeklyClasses'], WeeklyClass.fromJson),
    attendances: _list(json['attendances'], Attendance.fromJson),
    cancelledLessons: _list(json['cancelledLessons'], CancelledLesson.fromJson),
  );
}

List<T> _list<T>(Object? value, T Function(Map<String, Object?> json) decode) {
  return (value as List<dynamic>? ?? const [])
      .cast<Map<String, Object?>>()
      .map(decode)
      .toList();
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}

String dateKey(DateTime date) => _dateKey(date);

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
