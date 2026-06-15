import 'package:flutter/foundation.dart';

import '../data/diario_storage.dart';
import 'attendance_reporter.dart';
import 'grade_semanal.dart';
import 'models.dart';

class DashboardView {
  const DashboardView({
    required this.currentLesson,
    required this.nextLesson,
    required this.todaysLessons,
    required this.pendingLessons,
  });

  final LessonOccurrence? currentLesson;
  final LessonOccurrence? nextLesson;
  final List<LessonOccurrence> todaysLessons;
  final List<LessonOccurrence> pendingLessons;
}

abstract class DiarioDeClasse implements Listenable {
  Future<void> load();
  bool get isLoaded;
  bool get hasMinimumSetup;

  // Workflow: Dashboard
  DashboardView getDashboard(DateTime now);

  // Workflow: Attendance
  Future<Attendance> startAttendance(LessonOccurrence lesson);
  Future<void> markStudent(
    Attendance attendance,
    String studentId,
    AttendanceStatus status,
  );
  Future<void> togglePresence(Attendance attendance, String studentId);
  Future<void> closeAttendance(Attendance attendance);
  Future<void> reopenAttendance(Attendance attendance);
  Future<void> cancelLesson(LessonOccurrence lesson);

  // Workflow: Setup & Admin
  Future<void> completeOnboarding({
    required String turma,
    required String periodo,
    required String disciplina,
    required String alunos,
    required DateTime now,
  });
  Future<void> loadDemoData(DateTime now);

  Future<void> addClassGroup({
    required String turma,
    required String periodo,
    DateTime? termStartDate,
    DateTime? termEndDate,
  });
  Future<void> updateClassGroup({
    required String classGroupId,
    required String name,
    required String termName,
    DateTime? termStartDate,
    DateTime? termEndDate,
  });
  Future<void> addDiscipline(String name);
  Future<void> addStudents(String classGroupId, String names);
  Future<void> addStudent(String classGroupId, String name);
  Future<void> saveStudentPhotoBase64(Student student, String photoBase64);
  Future<void> addWeeklyClass({
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  });
  Future<void> removeWeeklyClass(String id);
  Future<void> updateWeeklyClass({
    required String id,
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  });

  // Queries
  List<Term> get terms;
  List<ClassGroup> get classGroups;
  List<Discipline> get disciplines;
  List<Student> get students;
  List<WeeklyClass> get weeklyClasses;

  List<Student> studentsForClass(String classGroupId);
  ClassGroup classGroup(String id);
  Discipline discipline(String id);
  Term term(String id);

  Attendance? attendanceFor(String lessonId);
  Attendance? attendanceById(String id);
  List<AttendanceSummary> summaries({
    String? classGroupId,
    String? disciplineId,
  });
  String csvExport({String? classGroupId, String? disciplineId});
  List<ClosedAttendanceView> closedAttendanceViews();
}

class DiarioDeClasseImpl with ChangeNotifier implements DiarioDeClasse {
  DiarioDeClasseImpl({
    required DiarioStorage storage,
    AttendanceReporter attendanceReporter = const AttendanceReporter(),
  }) : _storage = storage,
       _attendanceReporter = attendanceReporter;

  final DiarioStorage _storage;
  final AttendanceReporter _attendanceReporter;

  ProfData _data = const ProfData();
  GradeSemanal _gradeSemanal = GradeSemanal(
    weeklyClasses: [],
    classGroups: [],
    terms: [],
    cancelledLessons: [],
  );

  bool _isLoaded = false;
  int _idSequence = 0;

  @override
  bool get isLoaded => _isLoaded;

  @override
  bool get hasMinimumSetup =>
      classGroups.isNotEmpty &&
      disciplines.isNotEmpty &&
      terms.isNotEmpty &&
      weeklyClasses.isNotEmpty &&
      students.isNotEmpty;

  @override
  Future<void> load() async {
    final loaded = await _storage.loadAll();
    final hasDuplicateStudentIds = _hasDuplicateStudentIds(loaded);
    _data = hasDuplicateStudentIds
        ? _repairDuplicateStudentIds(loaded)
        : loaded;

    _gradeSemanal = GradeSemanal(
      weeklyClasses: _data.weeklyClasses.toList(),
      classGroups: _data.classGroups.toList(),
      terms: _data.terms.toList(),
      cancelledLessons: _data.cancelledLessons.toList(),
    );

    if (hasDuplicateStudentIds) {
      for (final student in _data.students) {
        await _storage.saveStudent(student);
      }
      for (final attendance in _data.attendances) {
        await _storage.saveAttendance(attendance);
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  @override
  DashboardView getDashboard(DateTime now) {
    final closedAttendanceLessonIds = _data.attendances
        .where((a) => a.isClosed)
        .map((a) => a.lessonId)
        .toSet();

    return DashboardView(
      currentLesson: _gradeSemanal.currentLesson(now),
      nextLesson: _gradeSemanal.nextLesson(now),
      todaysLessons: _gradeSemanal.todaysLessons(now),
      pendingLessons: _gradeSemanal.pendingLessons(
        now,
        closedAttendanceLessonIds,
      ),
    );
  }

  @override
  Future<void> completeOnboarding({
    required String turma,
    required String periodo,
    required String disciplina,
    required String alunos,
    required DateTime now,
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

    _gradeSemanal.addClassGroup(group, term);
    _gradeSemanal.addWeeklyClass(weeklyClass);

    _data = _data.copyWith(
      disciplines: [..._data.disciplines, discipline],
      students: [..._data.students, ...students],
    );
    await _storage.saveTerm(term);
    await _storage.saveClassGroup(group);
    await _storage.saveDiscipline(discipline);
    for (final s in students) {
      await _storage.saveStudent(s);
    }
    await _storage.saveWeeklyClass(weeklyClass);
    notifyListeners();
  }

  @override
  Future<void> addClassGroup({
    required String turma,
    required String periodo,
    DateTime? termStartDate,
    DateTime? termEndDate,
  }) async {
    final term = Term(
      id: _id('term'),
      name: periodo.trim(),
      startDate: termStartDate,
      endDate: termEndDate,
    );
    final group = ClassGroup(
      id: _id('turma'),
      name: turma.trim(),
      termId: term.id,
    );
    _gradeSemanal.addClassGroup(group, term);
    await _storage.saveTerm(term);
    await _storage.saveClassGroup(group);
    notifyListeners();
  }

  @override
  Future<void> updateClassGroup({
    required String classGroupId,
    required String name,
    required String termName,
    DateTime? termStartDate,
    DateTime? termEndDate,
  }) async {
    final group = classGroup(classGroupId);
    final updatedGroup = group.copyWith(name: name.trim());
    final updatedTerm = term(group.termId).copyWith(
      name: termName.trim(),
      startDate: termStartDate,
      endDate: termEndDate,
    );

    _gradeSemanal.updateClassGroup(updatedGroup, updatedTerm);
    await _storage.saveClassGroup(updatedGroup);
    await _storage.saveTerm(updatedTerm);
    notifyListeners();
  }

  @override
  Future<void> addDiscipline(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final discipline = Discipline(id: _id('disciplina'), name: trimmed);
    _data = _data.copyWith(disciplines: [..._data.disciplines, discipline]);
    await _storage.saveDiscipline(discipline);
    notifyListeners();
  }

  @override
  Future<void> addStudents(String classGroupId, String names) async {
    final students = _parseStudentNames(names)
        .map(
          (name) =>
              Student(id: _id('aluno'), classGroupId: classGroupId, name: name),
        )
        .toList();
    if (students.isEmpty) return;
    _data = _data.copyWith(students: [..._data.students, ...students]);
    for (final s in students) {
      await _storage.saveStudent(s);
    }
    notifyListeners();
  }

  @override
  Future<void> addStudent(String classGroupId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final student = Student(
      id: _id('aluno'),
      classGroupId: classGroupId,
      name: trimmed,
    );
    _data = _data.copyWith(students: [..._data.students, student]);
    await _storage.saveStudent(student);
    notifyListeners();
  }

  @override
  Future<void> addWeeklyClass({
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    final weeklyClass = WeeklyClass(
      id: _id('grade'),
      weekday: weekday,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      classGroupId: classGroupId,
      disciplineId: disciplineId,
    );
    _gradeSemanal.addWeeklyClass(weeklyClass);
    await _storage.saveWeeklyClass(weeklyClass);
    notifyListeners();
  }

  @override
  Future<void> removeWeeklyClass(String id) async {
    _gradeSemanal.removeWeeklyClass(id);
    await _storage.deleteWeeklyClass(id);
    notifyListeners();
  }

  @override
  Future<void> updateWeeklyClass({
    required String id,
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    final old = _gradeSemanal.weeklyClasses.firstWhere((c) => c.id == id);
    final updated = old.copyWith(
      classGroupId: classGroupId,
      disciplineId: disciplineId,
      weekday: weekday,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    _gradeSemanal.updateWeeklyClass(updated);
    await _storage.saveWeeklyClass(updated);
    notifyListeners();
  }

  @override
  List<Student> studentsForClass(String classGroupId) {
    final students =
        _data.students
            .where((student) => student.classGroupId == classGroupId)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return students;
  }

  @override
  ClassGroup classGroup(String id) =>
      _gradeSemanal.classGroups.firstWhere((item) => item.id == id);

  @override
  Discipline discipline(String id) =>
      _data.disciplines.firstWhere((item) => item.id == id);

  @override
  Term term(String id) =>
      _gradeSemanal.terms.firstWhere((item) => item.id == id);

  @override
  Attendance? attendanceFor(String lessonId) {
    for (final attendance in _data.attendances) {
      if (attendance.lessonId == lessonId) return attendance;
    }
    return null;
  }

  @override
  Attendance? attendanceById(String id) {
    for (final attendance in _data.attendances) {
      if (attendance.id == id) return attendance;
    }
    return null;
  }

  @override
  Future<Attendance> startAttendance(LessonOccurrence lesson) async {
    final existing = attendanceFor(lesson.id);
    if (existing != null) return existing;

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
    await _storage.saveAttendance(attendance);
    return attendance;
  }

  @override
  Future<void> markStudent(
    Attendance attendance,
    String studentId,
    AttendanceStatus status,
  ) async {
    final current = _currentAttendance(attendance);
    final updated = current.markStudent(studentId, status);
    await _replaceAttendance(updated);
    notifyListeners();
  }

  @override
  Future<void> togglePresence(Attendance attendance, String studentId) async {
    final current = _currentAttendance(attendance);
    final updated = current.togglePresence(studentId);
    await _replaceAttendance(updated);
    notifyListeners();
  }

  @override
  Future<void> closeAttendance(Attendance attendance) async {
    final current = _currentAttendance(attendance);
    await _replaceAttendance(current.close());
    notifyListeners();
  }

  @override
  Future<void> reopenAttendance(Attendance attendance) async {
    final current = _currentAttendance(attendance);
    await _replaceAttendance(current.reopen());
    notifyListeners();
  }

  @override
  Future<void> cancelLesson(LessonOccurrence lesson) async {
    final cancelled = CancelledLesson(lessonId: lesson.id);
    _gradeSemanal.cancelLesson(cancelled);
    await _storage.saveCancelledLesson(cancelled);
    notifyListeners();
  }

  @override
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
    await _storage.saveStudent(updated);
    notifyListeners();
  }

  @override
  List<AttendanceSummary> summaries({
    String? classGroupId,
    String? disciplineId,
  }) => _attendanceReporter.summaries(
    _composedData,
    classGroupId: classGroupId,
    disciplineId: disciplineId,
  );

  @override
  String csvExport({String? classGroupId, String? disciplineId}) =>
      _attendanceReporter.csvExport(
        _composedData,
        classGroupId: classGroupId,
        disciplineId: disciplineId,
      );

  @override
  List<ClosedAttendanceView> closedAttendanceViews() =>
      _attendanceReporter.closedAttendanceViews(_composedData);

  @override
  Future<void> loadDemoData(DateTime now) async {
    if (_data.hasMinimumSetup) return;
    await completeOnboarding(
      turma: 'DS3',
      periodo: '2026/1',
      disciplina: 'PAM2',
      alunos: 'Ana Silva\nBruno Costa\nCarla Rocha\nDiego Lima',
      now: now,
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
    notifyListeners();
  }

  Future<void> _replaceAttendance(Attendance updated) async {
    _data = _data.copyWith(
      attendances: [
        for (final attendance in _data.attendances)
          attendance.id == updated.id ? updated : attendance,
      ],
    );
    await _storage.saveAttendance(updated);
  }

  Attendance _currentAttendance(Attendance attendance) {
    for (final item in _data.attendances) {
      if (item.id == attendance.id) return item;
    }
    return attendance;
  }

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}';

  @override
  List<Term> get terms => _gradeSemanal.terms;

  @override
  List<ClassGroup> get classGroups => _gradeSemanal.classGroups;

  @override
  List<Discipline> get disciplines => _data.disciplines;

  @override
  List<Student> get students => _data.students;

  @override
  List<WeeklyClass> get weeklyClasses => _gradeSemanal.weeklyClasses;

  ProfData get _composedData => ProfData(
    classGroups: classGroups,
    terms: terms,
    disciplines: disciplines,
    students: students,
    weeklyClasses: weeklyClasses,
    attendances: _data.attendances,
    cancelledLessons: _gradeSemanal.cancelledLessons,
  );
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
    if (!seen.add(student.id)) return true;
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
