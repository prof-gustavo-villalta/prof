import 'package:flutter/foundation.dart';

import '../data/prof_repository.dart';
import '../domain/models.dart';
import '../domain/lesson_resolver.dart';
import '../domain/attendance_reporter.dart';

class ProfController extends ChangeNotifier {
  ProfController({
    required ProfRepository repository,
    DateTime? now,
    LessonOccurrenceResolver lessonResolver = const LessonOccurrenceResolver(),
    AttendanceReporter attendanceReporter = const AttendanceReporter(),
  })  : _repository = repository,
        _nowOverride = now,
        _lessonResolver = lessonResolver,
        _attendanceReporter = attendanceReporter;

  final ProfRepository _repository;
  final DateTime? _nowOverride;
  final LessonOccurrenceResolver _lessonResolver;
  final AttendanceReporter _attendanceReporter;
  ProfData _data = const ProfData();
  bool _isLoaded = false;
  int _selectedIndex = 0;
  int _idSequence = 0;

  ProfData get data => _data;

  bool get isLoaded => _isLoaded;

  int get selectedIndex => _selectedIndex;

  DateTime get now => _nowOverride ?? DateTime.now();

  Future<void> load() async {
    final loaded = await _repository.load();
    final hasDuplicateStudentIds = _hasDuplicateStudentIds(loaded);
    _data = hasDuplicateStudentIds
        ? _repairDuplicateStudentIds(loaded)
        : loaded;
    if (hasDuplicateStudentIds) {
      await _repository.save(_data);
    }
    _isLoaded = true;
    notifyListeners();
  }

  void selectTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String turma,
    required String periodo,
    required String disciplina,
    required String alunos,
  }) async {
    final term = Term(id: _id('term'), name: periodo.trim());
    final group = ClassGroup(
      id: _id('turma'),
      name: turma.trim(),
      termId: term.id,
    );
    final discipline = Discipline(
      id: _id('disciplina'),
      name: disciplina.trim(),
    );
    final students = _parseStudentNames(alunos)
        .map(
          (name) =>
              Student(id: _id('aluno'), classGroupId: group.id, name: name),
        )
        .toList();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = (currentMinutes - 15).clamp(0, 22 * 60).toInt();
    final weeklyClass = WeeklyClass(
      id: _id('grade'),
      weekday: now.weekday,
      startMinutes: startMinutes.clamp(0, 23 * 60).toInt(),
      endMinutes: (startMinutes + 120).clamp(1, 24 * 60 - 1).toInt(),
      classGroupId: group.id,
      disciplineId: discipline.id,
    );
    _data = _data.copyWith(
      terms: [..._data.terms, term],
      classGroups: [..._data.classGroups, group],
      disciplines: [..._data.disciplines, discipline],
      students: [..._data.students, ...students],
      weeklyClasses: [..._data.weeklyClasses, weeklyClass],
    );
    await _persist();
  }

  Future<void> addClassGroup({
    required String turma,
    required String periodo,
  }) async {
    final term = Term(id: _id('term'), name: periodo.trim());
    final group = ClassGroup(
      id: _id('turma'),
      name: turma.trim(),
      termId: term.id,
    );
    _data = _data.copyWith(
      terms: [..._data.terms, term],
      classGroups: [..._data.classGroups, group],
    );
    await _persist();
  }

  Future<void> updateClassGroup({
    required String classGroupId,
    required String name,
    required String termName,
    DateTime? termStartDate,
    DateTime? termEndDate,
  }) async {
    final group = classGroup(classGroupId);
    _data = _data.copyWith(
      classGroups: [
        for (final item in _data.classGroups)
          item.id == classGroupId ? item.copyWith(name: name.trim()) : item,
      ],
      terms: [
        for (final item in _data.terms)
          item.id == group.termId
              ? item.copyWith(
                  name: termName.trim(),
                  startDate: termStartDate,
                  endDate: termEndDate,
                )
              : item,
      ],
    );
    await _persist();
  }

  Future<void> addDiscipline(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _data = _data.copyWith(
      disciplines: [
        ..._data.disciplines,
        Discipline(id: _id('disciplina'), name: trimmed),
      ],
    );
    await _persist();
  }

  Future<void> addStudents(String classGroupId, String names) async {
    final students = _parseStudentNames(names)
        .map(
          (name) =>
              Student(id: _id('aluno'), classGroupId: classGroupId, name: name),
        )
        .toList();
    if (students.isEmpty) {
      return;
    }
    _data = _data.copyWith(students: [..._data.students, ...students]);
    await _persist();
  }

  Future<void> addStudent(String classGroupId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _data = _data.copyWith(
      students: [
        ..._data.students,
        Student(id: _id('aluno'), classGroupId: classGroupId, name: trimmed),
      ],
    );
    await _persist();
  }

  Future<void> addWeeklyClass({
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    _data = _data.copyWith(
      weeklyClasses: [
        ..._data.weeklyClasses,
        WeeklyClass(
          id: _id('grade'),
          weekday: weekday,
          startMinutes: startMinutes,
          endMinutes: endMinutes,
          classGroupId: classGroupId,
          disciplineId: disciplineId,
        ),
      ],
    );
    await _persist();
  }

  Future<void> removeWeeklyClass(String id) async {
    _data = _data.copyWith(
      weeklyClasses: [
        for (final weeklyClass in _data.weeklyClasses)
          if (weeklyClass.id != id) weeklyClass,
      ],
    );
    await _persist();
  }

  Future<void> updateWeeklyClass({
    required String id,
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    _data = _data.copyWith(
      weeklyClasses: [
        for (final weeklyClass in _data.weeklyClasses)
          weeklyClass.id == id
              ? weeklyClass.copyWith(
                  classGroupId: classGroupId,
                  disciplineId: disciplineId,
                  weekday: weekday,
                  startMinutes: startMinutes,
                  endMinutes: endMinutes,
                )
              : weeklyClass,
      ],
    );
    await _persist();
  }

  List<Student> studentsForClass(String classGroupId) {
    final students =
        _data.students
            .where((student) => student.classGroupId == classGroupId)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return students;
  }

  ClassGroup classGroup(String id) =>
      _data.classGroups.firstWhere((item) => item.id == id);

  Discipline discipline(String id) =>
      _data.disciplines.firstWhere((item) => item.id == id);

  Term term(String id) => _data.terms.firstWhere((item) => item.id == id);

  LessonOccurrence? currentLesson() => _lessonResolver.currentLesson(_data, now);

  LessonOccurrence? nextLesson() => _lessonResolver.nextLesson(_data, now);

  List<LessonOccurrence> todaysLessons() => _lessonResolver.todaysLessons(_data, now);

  List<LessonOccurrence> pendingLessons() => _lessonResolver.pendingLessons(_data, now);

  Attendance? attendanceFor(String lessonId) {
    for (final attendance in _data.attendances) {
      if (attendance.lessonId == lessonId) {
        return attendance;
      }
    }
    return null;
  }

  Future<Attendance> startAttendance(LessonOccurrence lesson) async {
    final existing = attendanceFor(lesson.id);
    if (existing != null) {
      return existing;
    }
    final statuses = {
      for (final student in studentsForClass(lesson.weeklyClass.classGroupId))
        student.id: AttendanceStatus.absent,
    };
    final attendance = Attendance(
      id: _id('chamada'),
      lessonId: lesson.id,
      weeklyClassId: lesson.weeklyClass.id,
      date: lesson.date,
      isClosed: false,
      statusByStudentId: statuses,
    );
    _data = _data.copyWith(attendances: [..._data.attendances, attendance]);
    await _persist();
    return attendance;
  }

  Future<void> markStudent(
    Attendance attendance,
    String studentId,
    AttendanceStatus status,
  ) async {
    final current = _currentAttendance(attendance);
    final updated = current.copyWith(
      statusByStudentId: {...current.statusByStudentId, studentId: status},
    );
    await _replaceAttendance(updated);
  }

  Future<void> togglePresence(Attendance attendance, String studentId) async {
    final currentAttendance = _currentAttendance(attendance);
    final current =
        currentAttendance.statusByStudentId[studentId] ??
        AttendanceStatus.absent;
    await markStudent(
      currentAttendance,
      studentId,
      current == AttendanceStatus.present
          ? AttendanceStatus.absent
          : AttendanceStatus.present,
    );
  }

  Future<void> closeAttendance(Attendance attendance) async {
    await _replaceAttendance(attendance.copyWith(isClosed: true));
  }

  Future<void> reopenAttendance(Attendance attendance) async {
    await _replaceAttendance(attendance.copyWith(isClosed: false));
  }

  Future<void> cancelLesson(LessonOccurrence lesson) async {
    if (_lessonResolver.isCancelled(_data, lesson.id)) {
      return;
    }
    _data = _data.copyWith(
      cancelledLessons: [
        ..._data.cancelledLessons,
        CancelledLesson(lessonId: lesson.id),
      ],
    );
    await _persist();
  }



  Future<void> saveStudentPhotoBase64(
    Student student,
    String photoBase64,
  ) async {
    final updated = student.copyWith(photoBase64: photoBase64);
    _data = _data.copyWith(
      students: [
        for (final item in _data.students)
          item.id == student.id ? updated : item,
      ],
    );
    await _persist();
  }

  List<AttendanceSummary> summaries({
    String? classGroupId,
    String? disciplineId,
  }) => _attendanceReporter.summaries(
        _data,
        classGroupId: classGroupId,
        disciplineId: disciplineId,
      );

  String csvExport({String? classGroupId, String? disciplineId}) =>
      _attendanceReporter.csvExport(
        _data,
        classGroupId: classGroupId,
        disciplineId: disciplineId,
      );

  List<ClosedAttendanceView> closedAttendanceViews() =>
      _attendanceReporter.closedAttendanceViews(_data);

  Future<void> loadDemoData() async {
    if (_data.hasMinimumSetup) {
      return;
    }
    await completeOnboarding(
      turma: 'DS3',
      periodo: '2026/1',
      disciplina: 'PAM2',
      alunos: 'Ana Silva\nBruno Costa\nCarla Rocha\nDiego Lima',
    );
    await saveStudentPhotoBase64(_data.students.first, demoStudentPhotoBase64);
    await addDiscipline('WEB2');
    await addWeeklyClass(
      classGroupId: _data.classGroups.first.id,
      disciplineId: _data.disciplines.last.id,
      weekday: now.weekday,
      startMinutes: (now.hour * 60 + now.minute + 180).clamp(0, 23 * 60),
      endMinutes: (now.hour * 60 + now.minute + 300).clamp(1, 24 * 60 - 1),
    );
  }

  Future<void> _replaceAttendance(Attendance updated) async {
    _data = _data.copyWith(
      attendances: [
        for (final attendance in _data.attendances)
          attendance.id == updated.id ? updated : attendance,
      ],
    );
    await _persist();
  }

  Attendance _currentAttendance(Attendance attendance) {
    for (final item in _data.attendances) {
      if (item.id == attendance.id) {
        return item;
      }
    }
    return attendance;
  }

  Future<void> _persist() async {
    await _repository.save(_data);
    notifyListeners();
  }



  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}';
}

const demoStudentPhotoBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADElEQVR4nGNgYPgPAAEDAQC3FWqWAAAAAElFTkSuQmCC';

List<String> _parseStudentNames(String names) {
  return names
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}

bool _hasDuplicateStudentIds(ProfData data) {
  final seen = <String>{};
  for (final student in data.students) {
    if (!seen.add(student.id)) {
      return true;
    }
  }
  return false;
}

ProfData _repairDuplicateStudentIds(ProfData data) {
  var sequence = 0;
  final usedIds = <String>{};
  final duplicateIds = <String, List<String>>{};
  final repairedStudents = <Student>[];

  String nextStudentId() {
    String id;
    do {
      id =
          'aluno-repaired-${DateTime.now().microsecondsSinceEpoch}-${sequence++}';
    } while (usedIds.contains(id));
    usedIds.add(id);
    return id;
  }

  for (final student in data.students) {
    if (usedIds.add(student.id)) {
      repairedStudents.add(student);
      continue;
    }

    final repairedId = nextStudentId();
    duplicateIds.putIfAbsent(student.id, () => []).add(repairedId);
    repairedStudents.add(
      Student(
        id: repairedId,
        classGroupId: student.classGroupId,
        name: student.name,
        photoBase64: student.photoBase64,
      ),
    );
  }

  final repairedAttendances = [
    for (final attendance in data.attendances)
      attendance.copyWith(
        statusByStudentId: {
          ...attendance.statusByStudentId,
          for (final ids in duplicateIds.values)
            for (final id in ids) id: AttendanceStatus.absent,
        },
      ),
  ];

  return data.copyWith(
    students: repairedStudents,
    attendances: repairedAttendances,
  );
}
