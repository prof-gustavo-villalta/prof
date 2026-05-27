import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../domain/diario_de_classe.dart';

class ProfController extends ChangeNotifier {
  ProfController({
    required DiarioDeClasse diario,
    DateTime? now,
  })  : _diario = diario,
        _nowOverride = now;

  final DiarioDeClasse _diario;
  final DateTime? _nowOverride;
  int _selectedIndex = 0;

  bool get isLoaded => _diario.isLoaded;
  bool get hasMinimumSetup => _diario.hasMinimumSetup;
  int get selectedIndex => _selectedIndex;
  DateTime get now => _nowOverride ?? DateTime.now();
  DashboardView get dashboard => _diario.getDashboard(now);
  
  @visibleForTesting
  DiarioDeClasse get diario => _diario;
  
  @visibleForTesting
  ProfData get data => (_diario as DiarioDeClasseImpl).dataForTesting;

  List<ClassGroup> get classGroups => _diario.classGroups;
  List<Discipline> get disciplines => _diario.disciplines;
  List<WeeklyClass> get weeklyClasses => _diario.weeklyClasses;

  Future<void> load() async {
    await _diario.load();
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
    await _diario.completeOnboarding(
      turma: turma,
      periodo: periodo,
      disciplina: disciplina,
      alunos: alunos,
      now: now,
    );
    notifyListeners();
  }

  Future<void> addClassGroup({required String turma, required String periodo}) async {
    await _diario.addClassGroup(turma: turma, periodo: periodo);
    notifyListeners();
  }

  Future<void> updateClassGroup({
    required String classGroupId,
    required String name,
    required String termName,
    DateTime? termStartDate,
    DateTime? termEndDate,
  }) async {
    await _diario.updateClassGroup(
      classGroupId: classGroupId,
      name: name,
      termName: termName,
      termStartDate: termStartDate,
      termEndDate: termEndDate,
    );
    notifyListeners();
  }

  Future<void> addDiscipline(String name) async {
    await _diario.addDiscipline(name);
    notifyListeners();
  }

  Future<void> addStudents(String classGroupId, String names) async {
    await _diario.addStudents(classGroupId, names);
    notifyListeners();
  }

  Future<void> addStudent(String classGroupId, String name) async {
    await _diario.addStudent(classGroupId, name);
    notifyListeners();
  }

  Future<void> addWeeklyClass({
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    await _diario.addWeeklyClass(
      classGroupId: classGroupId,
      disciplineId: disciplineId,
      weekday: weekday,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    notifyListeners();
  }

  Future<void> removeWeeklyClass(String id) async {
    await _diario.removeWeeklyClass(id);
    notifyListeners();
  }

  Future<void> updateWeeklyClass({
    required String id,
    required String classGroupId,
    required String disciplineId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    await _diario.updateWeeklyClass(
      id: id,
      classGroupId: classGroupId,
      disciplineId: disciplineId,
      weekday: weekday,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    notifyListeners();
  }

  List<Student> studentsForClass(String classGroupId) => _diario.studentsForClass(classGroupId);
  ClassGroup classGroup(String id) => _diario.classGroup(id);
  Discipline discipline(String id) => _diario.discipline(id);
  Term term(String id) => _diario.term(id);
  
  LessonOccurrence? currentLesson() => dashboard.currentLesson;
  LessonOccurrence? nextLesson() => dashboard.nextLesson;
  List<LessonOccurrence> todaysLessons() => dashboard.todaysLessons;
  List<LessonOccurrence> pendingLessons() => dashboard.pendingLessons;

  Attendance? attendanceFor(String lessonId) => _diario.attendanceFor(lessonId);
  Attendance? attendanceById(String id) => _diario.attendanceById(id);

  Future<Attendance> startAttendance(LessonOccurrence lesson) async {
    final result = await _diario.startAttendance(lesson);
    notifyListeners();
    return result;
  }

  Future<void> markStudent(Attendance attendance, String studentId, AttendanceStatus status) async {
    await _diario.markStudent(attendance, studentId, status);
    notifyListeners();
  }

  Future<void> togglePresence(Attendance attendance, String studentId) async {
    await _diario.togglePresence(attendance, studentId);
    notifyListeners();
  }

  Future<void> closeAttendance(Attendance attendance) async {
    await _diario.closeAttendance(attendance);
    notifyListeners();
  }

  Future<void> reopenAttendance(Attendance attendance) async {
    await _diario.reopenAttendance(attendance);
    notifyListeners();
  }

  Future<void> cancelLesson(LessonOccurrence lesson) async {
    await _diario.cancelLesson(lesson);
    notifyListeners();
  }

  Future<void> saveStudentPhotoBase64(Student student, String photoBase64) async {
    await _diario.saveStudentPhotoBase64(student, photoBase64);
    notifyListeners();
  }

  List<AttendanceSummary> summaries({String? classGroupId, String? disciplineId}) =>
      _diario.summaries(classGroupId: classGroupId, disciplineId: disciplineId);

  String csvExport({String? classGroupId, String? disciplineId}) =>
      _diario.csvExport(classGroupId: classGroupId, disciplineId: disciplineId);

  List<ClosedAttendanceView> closedAttendanceViews() => _diario.closedAttendanceViews();

  Future<void> loadDemoData() async {
    await _diario.loadDemoData(now);
    notifyListeners();
  }

}

