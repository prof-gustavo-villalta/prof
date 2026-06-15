import 'models.dart';

class GradeSemanal {
  GradeSemanal({
    required List<WeeklyClass> weeklyClasses,
    required List<ClassGroup> classGroups,
    required List<Term> terms,
    required List<CancelledLesson> cancelledLessons,
  }) : _weeklyClasses = List.from(weeklyClasses),
       _classGroups = List.from(classGroups),
       _terms = List.from(terms),
       _cancelledLessons = List.from(cancelledLessons);

  final List<WeeklyClass> _weeklyClasses;
  final List<ClassGroup> _classGroups;
  final List<Term> _terms;
  final List<CancelledLesson> _cancelledLessons;

  // Getters for read-only access
  List<WeeklyClass> get weeklyClasses => List.unmodifiable(_weeklyClasses);
  List<ClassGroup> get classGroups => List.unmodifiable(_classGroups);
  List<Term> get terms => List.unmodifiable(_terms);
  List<CancelledLesson> get cancelledLessons =>
      List.unmodifiable(_cancelledLessons);

  // Mutations
  void addClassGroup(ClassGroup group, Term term) {
    _classGroups.add(group);
    _terms.add(term);
  }

  void updateClassGroup(ClassGroup updatedGroup, Term updatedTerm) {
    final groupIndex = _classGroups.indexWhere((g) => g.id == updatedGroup.id);
    if (groupIndex >= 0) _classGroups[groupIndex] = updatedGroup;

    final termIndex = _terms.indexWhere((t) => t.id == updatedTerm.id);
    if (termIndex >= 0) _terms[termIndex] = updatedTerm;
  }

  void addWeeklyClass(WeeklyClass weeklyClass) {
    _weeklyClasses.add(weeklyClass);
  }

  void updateWeeklyClass(WeeklyClass updated) {
    final index = _weeklyClasses.indexWhere((c) => c.id == updated.id);
    if (index >= 0) _weeklyClasses[index] = updated;
  }

  void removeWeeklyClass(String id) {
    _weeklyClasses.removeWhere((c) => c.id == id);
  }

  void cancelLesson(CancelledLesson cancelled) {
    if (!_cancelledLessons.any((item) => item.lessonId == cancelled.lessonId)) {
      _cancelledLessons.add(cancelled);
    }
  }

  // Dashboard & Schedule Logic
  bool _isCancelled(String lessonId) {
    return _cancelledLessons.any((item) => item.lessonId == lessonId);
  }

  bool _withinTerm(LessonOccurrence lesson) {
    final group = _classGroups.firstWhere(
      (item) => item.id == lesson.weeklyClass.classGroupId,
    );
    final currentTerm = _terms.firstWhere((item) => item.id == group.termId);
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

  LessonOccurrence? currentLesson(DateTime now) {
    for (final weeklyClass in _weeklyClasses) {
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

  LessonOccurrence? nextLesson(DateTime now) {
    LessonOccurrence? next;
    for (var offset = 0; offset < 21; offset += 1) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: offset));
      for (final weeklyClass in _weeklyClasses) {
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

  List<LessonOccurrence> todaysLessons(DateTime now) {
    final lessons =
        _weeklyClasses
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

  List<LessonOccurrence> pendingLessons(
    DateTime now,
    Set<String> closedAttendanceLessonIds,
  ) {
    final pending = <LessonOccurrence>[];
    final today = DateTime(now.year, now.month, now.day);
    for (var offset = 1; offset <= 21; offset += 1) {
      final date = today.subtract(Duration(days: offset));
      for (final weeklyClass in _weeklyClasses) {
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
        if (!closedAttendanceLessonIds.contains(occurrence.id)) {
          pending.add(occurrence);
        }
      }
    }
    pending.sort((a, b) => b.start.compareTo(a.start));
    return pending;
  }
}
