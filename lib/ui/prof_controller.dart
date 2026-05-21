import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../data/prof_repository.dart';
import '../domain/models.dart';

class ProfController extends ChangeNotifier {
  ProfController({required ProfRepository repository, DateTime? now})
    : _repository = repository,
      _nowOverride = now;

  final ProfRepository _repository;
  final DateTime? _nowOverride;
  ProfData _data = const ProfData();
  bool _isLoaded = false;
  int _selectedIndex = 0;
  String _statusFilter = 'Todos';
  String _studentQuery = '';

  ProfData get data => _data;

  bool get isLoaded => _isLoaded;

  int get selectedIndex => _selectedIndex;

  String get statusFilter => _statusFilter;

  String get studentQuery => _studentQuery;

  DateTime get now => _nowOverride ?? DateTime.now();

  Future<void> load() async {
    _data = await _repository.load();
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

  LessonOccurrence? currentLesson() {
    for (final weeklyClass in _data.weeklyClasses) {
      final occurrence = LessonOccurrence(weeklyClass: weeklyClass, date: now);
      if (weeklyClass.weekday == now.weekday &&
          !_isCancelled(occurrence.id) &&
          !now.isBefore(occurrence.start) &&
          now.isBefore(occurrence.end) &&
          _withinTerm(occurrence)) {
        return occurrence;
      }
    }
    return null;
  }

  LessonOccurrence? nextLesson() {
    LessonOccurrence? next;
    for (var offset = 0; offset < 21; offset += 1) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: offset));
      for (final weeklyClass in _data.weeklyClasses) {
        if (weeklyClass.weekday != date.weekday) {
          continue;
        }
        final occurrence = LessonOccurrence(
          weeklyClass: weeklyClass,
          date: date,
        );
        if (_isCancelled(occurrence.id) || !_withinTerm(occurrence)) {
          continue;
        }
        if (!occurrence.end.isAfter(now)) {
          continue;
        }
        if (next == null || occurrence.start.isBefore(next.start)) {
          next = occurrence;
        }
      }
      if (next != null && offset == 0) {
        return next;
      }
    }
    return next;
  }

  List<LessonOccurrence> todaysLessons() {
    final lessons =
        _data.weeklyClasses
            .where((weeklyClass) => weeklyClass.weekday == now.weekday)
            .map(
              (weeklyClass) =>
                  LessonOccurrence(weeklyClass: weeklyClass, date: now),
            )
            .where((lesson) => !_isCancelled(lesson.id) && _withinTerm(lesson))
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return lessons;
  }

  List<LessonOccurrence> pendingLessons() {
    final pending = <LessonOccurrence>[];
    final today = DateTime(now.year, now.month, now.day);
    for (var offset = 1; offset <= 21; offset += 1) {
      final date = today.subtract(Duration(days: offset));
      for (final weeklyClass in _data.weeklyClasses) {
        if (weeklyClass.weekday != date.weekday) {
          continue;
        }
        final occurrence = LessonOccurrence(
          weeklyClass: weeklyClass,
          date: date,
        );
        if (_isCancelled(occurrence.id) || !_withinTerm(occurrence)) {
          continue;
        }
        final attendance = attendanceFor(occurrence.id);
        if (attendance == null || !attendance.isClosed) {
          pending.add(occurrence);
        }
      }
    }
    pending.sort((a, b) => b.start.compareTo(a.start));
    return pending;
  }

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
    final updated = attendance.copyWith(
      statusByStudentId: {...attendance.statusByStudentId, studentId: status},
    );
    await _replaceAttendance(updated);
  }

  Future<void> togglePresence(Attendance attendance, String studentId) async {
    final current =
        attendance.statusByStudentId[studentId] ?? AttendanceStatus.absent;
    await markStudent(
      attendance,
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
    if (_isCancelled(lesson.id)) {
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

  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setStudentQuery(String value) {
    _studentQuery = value;
    notifyListeners();
  }

  List<Student> visibleAttendanceStudents(Attendance attendance) {
    final weeklyClass = _data.weeklyClasses.firstWhere(
      (item) => item.id == attendance.weeklyClassId,
    );
    return studentsForClass(weeklyClass.classGroupId).where((student) {
      final matchesQuery = student.name.toLowerCase().contains(
        _studentQuery.trim().toLowerCase(),
      );
      final status =
          attendance.statusByStudentId[student.id] ?? AttendanceStatus.absent;
      final matchesFilter =
          _statusFilter == 'Todos' ||
          (_statusFilter == 'Presentes' &&
              status == AttendanceStatus.present) ||
          (_statusFilter == 'Ausentes' && status == AttendanceStatus.absent) ||
          (_statusFilter == 'Atrasos' && status == AttendanceStatus.late) ||
          (_statusFilter == 'Justificados' &&
              status == AttendanceStatus.justified);
      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> pickStudentPhoto(Student student, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1024);
    if (image == null) {
      return;
    }
    final bytes = await image.readAsBytes();
    await saveStudentPhotoBase64(student, base64Encode(bytes));
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

  List<AttendanceSummary> summaries() {
    final result = <AttendanceSummary>[];
    final closed = _data.attendances.where((attendance) => attendance.isClosed);
    for (final student in _data.students) {
      for (final weeklyClass in _data.weeklyClasses.where(
        (item) => item.classGroupId == student.classGroupId,
      )) {
        final attendances = closed
            .where((item) => item.weeklyClassId == weeklyClass.id)
            .toList();
        if (attendances.isEmpty) {
          continue;
        }
        var present = 0;
        var late = 0;
        var absent = 0;
        var justified = 0;
        for (final attendance in attendances) {
          switch (attendance.statusByStudentId[student.id] ??
              AttendanceStatus.absent) {
            case AttendanceStatus.present:
              present += 1;
              break;
            case AttendanceStatus.late:
              late += 1;
              break;
            case AttendanceStatus.absent:
              absent += 1;
              break;
            case AttendanceStatus.justified:
              justified += 1;
              break;
          }
        }
        result.add(
          AttendanceSummary(
            student: student,
            classGroup: classGroup(weeklyClass.classGroupId),
            discipline: discipline(weeklyClass.disciplineId),
            term: term(classGroup(weeklyClass.classGroupId).termId),
            calledLessons: attendances.length,
            present: present,
            late: late,
            absent: absent,
            justified: justified,
          ),
        );
      }
    }
    result.sort((a, b) => a.student.name.compareTo(b.student.name));
    return result;
  }

  String csvExport() {
    final rows = [
      [
        'Aluno',
        'Turma',
        'Disciplina',
        'Periodo letivo',
        'Aulas chamadas',
        'Presencas',
        'Atrasos',
        'Ausencias',
        'Justificativas',
        'Percentual de presenca',
      ],
      for (final summary in summaries())
        [
          summary.student.name,
          summary.classGroup.name,
          summary.discipline.name,
          summary.term.name,
          '${summary.calledLessons}',
          '${summary.present}',
          '${summary.late}',
          '${summary.absent}',
          '${summary.justified}',
          '${summary.presencePercent}%',
        ],
    ];
    return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

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

  Future<void> _persist() async {
    await _repository.save(_data);
    notifyListeners();
  }

  bool _isCancelled(String lessonId) =>
      _data.cancelledLessons.any((item) => item.lessonId == lessonId);

  bool _withinTerm(LessonOccurrence lesson) {
    final group = classGroup(lesson.weeklyClass.classGroupId);
    final currentTerm = term(group.termId);
    final day = DateTime(lesson.date.year, lesson.date.month, lesson.date.day);
    final start = currentTerm.startDate;
    final end = currentTerm.endDate;
    if (start != null &&
        day.isBefore(DateTime(start.year, start.month, start.day))) {
      return false;
    }
    if (end != null && day.isAfter(DateTime(end.year, end.month, end.day))) {
      return false;
    }
    return true;
  }

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_data.hashCode}';
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.student,
    required this.classGroup,
    required this.discipline,
    required this.term,
    required this.calledLessons,
    required this.present,
    required this.late,
    required this.absent,
    required this.justified,
  });

  final Student student;
  final ClassGroup classGroup;
  final Discipline discipline;
  final Term term;
  final int calledLessons;
  final int present;
  final int late;
  final int absent;
  final int justified;

  int get presencePercent {
    if (calledLessons == 0) {
      return 0;
    }
    return (((present + late) / calledLessons) * 100).round();
  }
}

List<String> _parseStudentNames(String names) {
  return names
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}

String _csvCell(String value) {
  if (!value.contains(',') && !value.contains('"') && !value.contains('\n')) {
    return value;
  }
  return '"${value.replaceAll('"', '""')}"';
}
