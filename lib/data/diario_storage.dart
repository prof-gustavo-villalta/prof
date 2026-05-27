import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

abstract class DiarioStorage {
  Future<ProfData> loadAll();

  Future<void> saveTerm(Term term);
  Future<void> saveClassGroup(ClassGroup classGroup);
  Future<void> saveDiscipline(Discipline discipline);
  Future<void> saveStudent(Student student);
  Future<void> saveWeeklyClass(WeeklyClass weeklyClass);
  Future<void> deleteWeeklyClass(String id);
  Future<void> saveAttendance(Attendance attendance);
  Future<void> saveCancelledLesson(CancelledLesson cancelledLesson);
}

class SharedPreferencesDiarioStorage implements DiarioStorage {
  const SharedPreferencesDiarioStorage();

  @override
  Future<ProfData> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final legacyData = prefs.getString('prof.data.v1');
    if (legacyData != null && legacyData.isNotEmpty) {
      final data = ProfData.fromJson(jsonDecode(legacyData) as Map<String, Object?>);
      await _migrate(prefs, data);
      await prefs.remove('prof.data.v1');
      return data;
    }

    final keys = prefs.getKeys();

    final terms = <Term>[];
    final classGroups = <ClassGroup>[];
    final disciplines = <Discipline>[];
    final students = <Student>[];
    final weeklyClasses = <WeeklyClass>[];
    final attendances = <Attendance>[];
    final cancelledLessons = <CancelledLesson>[];

    for (final key in keys) {
      if (!key.startsWith('prof.')) continue;

      final raw = prefs.getString(key);
      if (raw == null) continue;

      final json = jsonDecode(raw) as Map<String, Object?>;

      if (key.startsWith('prof.term.')) {
        terms.add(Term.fromJson(json));
      } else if (key.startsWith('prof.group.')) {
        classGroups.add(ClassGroup.fromJson(json));
      } else if (key.startsWith('prof.disc.')) {
        disciplines.add(Discipline.fromJson(json));
      } else if (key.startsWith('prof.student.')) {
        students.add(Student.fromJson(json));
      } else if (key.startsWith('prof.weekly.')) {
        weeklyClasses.add(WeeklyClass.fromJson(json));
      } else if (key.startsWith('prof.att.')) {
        attendances.add(Attendance.fromJson(json));
      } else if (key.startsWith('prof.canc.')) {
        cancelledLessons.add(CancelledLesson.fromJson(json));
      }
    }

    return ProfData(
      terms: terms,
      classGroups: classGroups,
      disciplines: disciplines,
      students: students,
      weeklyClasses: weeklyClasses,
      attendances: attendances,
      cancelledLessons: cancelledLessons,
    );
  }

  Future<void> _migrate(SharedPreferences prefs, ProfData data) async {
    for (final t in data.terms) {
      await saveTerm(t);
    }
    for (final c in data.classGroups) {
      await saveClassGroup(c);
    }
    for (final d in data.disciplines) {
      await saveDiscipline(d);
    }
    for (final s in data.students) {
      await saveStudent(s);
    }
    for (final w in data.weeklyClasses) {
      await saveWeeklyClass(w);
    }
    for (final a in data.attendances) {
      await saveAttendance(a);
    }
    for (final c in data.cancelledLessons) {
      await saveCancelledLesson(c);
    }
  }

  Future<void> _saveEntity(String prefix, String id, Map<String, Object?> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$prefix$id', jsonEncode(json));
  }

  @override
  Future<void> saveTerm(Term term) => _saveEntity('prof.term.', term.id, term.toJson());

  @override
  Future<void> saveClassGroup(ClassGroup classGroup) =>
      _saveEntity('prof.group.', classGroup.id, classGroup.toJson());

  @override
  Future<void> saveDiscipline(Discipline discipline) =>
      _saveEntity('prof.disc.', discipline.id, discipline.toJson());

  @override
  Future<void> saveStudent(Student student) =>
      _saveEntity('prof.student.', student.id, student.toJson());

  @override
  Future<void> saveWeeklyClass(WeeklyClass weeklyClass) =>
      _saveEntity('prof.weekly.', weeklyClass.id, weeklyClass.toJson());

  @override
  Future<void> deleteWeeklyClass(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('prof.weekly.$id');
  }

  @override
  Future<void> saveAttendance(Attendance attendance) =>
      _saveEntity('prof.att.', attendance.id, attendance.toJson());

  @override
  Future<void> saveCancelledLesson(CancelledLesson cancelledLesson) =>
      _saveEntity('prof.canc.', cancelledLesson.lessonId, cancelledLesson.toJson());
}

class InMemoryDiarioStorage implements DiarioStorage {
  InMemoryDiarioStorage([this._data = const ProfData()]);

  ProfData _data;

  @override
  Future<ProfData> loadAll() async => _data;

  @override
  Future<void> saveTerm(Term term) async {
    final list = _data.terms.toList()..removeWhere((item) => item.id == term.id)..add(term);
    _data = _data.copyWith(terms: list);
  }

  @override
  Future<void> saveClassGroup(ClassGroup classGroup) async {
    final list = _data.classGroups.toList()..removeWhere((item) => item.id == classGroup.id)..add(classGroup);
    _data = _data.copyWith(classGroups: list);
  }

  @override
  Future<void> saveDiscipline(Discipline discipline) async {
    final list = _data.disciplines.toList()..removeWhere((item) => item.id == discipline.id)..add(discipline);
    _data = _data.copyWith(disciplines: list);
  }

  @override
  Future<void> saveStudent(Student student) async {
    final list = _data.students.toList()..removeWhere((item) => item.id == student.id)..add(student);
    _data = _data.copyWith(students: list);
  }

  @override
  Future<void> saveWeeklyClass(WeeklyClass weeklyClass) async {
    final list = _data.weeklyClasses.toList()..removeWhere((item) => item.id == weeklyClass.id)..add(weeklyClass);
    _data = _data.copyWith(weeklyClasses: list);
  }

  @override
  Future<void> deleteWeeklyClass(String id) async {
    final list = _data.weeklyClasses.toList()..removeWhere((item) => item.id == id);
    _data = _data.copyWith(weeklyClasses: list);
  }

  @override
  Future<void> saveAttendance(Attendance attendance) async {
    final list = _data.attendances.toList()..removeWhere((item) => item.id == attendance.id)..add(attendance);
    _data = _data.copyWith(attendances: list);
  }

  @override
  Future<void> saveCancelledLesson(CancelledLesson cancelledLesson) async {
    final list = _data.cancelledLessons.toList()..removeWhere((item) => item.lessonId == cancelledLesson.lessonId)..add(cancelledLesson);
    _data = _data.copyWith(cancelledLessons: list);
  }
}
