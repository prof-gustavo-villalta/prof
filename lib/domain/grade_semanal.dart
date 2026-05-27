import 'models.dart';

class GradeSemanal {
  const GradeSemanal({
    required this.weeklyClasses,
    required this.classGroups,
    required this.terms,
    required this.cancelledLessons,
    required this.closedAttendanceLessonIds,
  });

  final List<WeeklyClass> weeklyClasses;
  final List<ClassGroup> classGroups;
  final List<Term> terms;
  final List<CancelledLesson> cancelledLessons;
  final Set<String> closedAttendanceLessonIds;

  bool _isCancelled(String lessonId) {
    return cancelledLessons.any((item) => item.lessonId == lessonId);
  }

  bool _withinTerm(LessonOccurrence lesson) {
    final group = classGroups.firstWhere((item) => item.id == lesson.weeklyClass.classGroupId);
    final currentTerm = terms.firstWhere((item) => item.id == group.termId);
    final day = DateTime(lesson.date.year, lesson.date.month, lesson.date.day);
    final start = currentTerm.startDate;
    final end = currentTerm.endDate;
    if (start != null && day.isBefore(DateTime(start.year, start.month, start.day))) {
      return false;
    }
    if (end != null && day.isAfter(DateTime(end.year, end.month, end.day))) {
      return false;
    }
    return true;
  }

  LessonOccurrence? currentLesson(DateTime now) {
    for (final weeklyClass in weeklyClasses) {
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
      for (final weeklyClass in weeklyClasses) {
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
    final lessons = weeklyClasses
        .where((weeklyClass) => weeklyClass.weekday == now.weekday)
        .map(
          (weeklyClass) => LessonOccurrence(weeklyClass: weeklyClass, date: now),
        )
        .where((lesson) => !_isCancelled(lesson.id) && _withinTerm(lesson))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return lessons;
  }

  List<LessonOccurrence> pendingLessons(DateTime now) {
    final pending = <LessonOccurrence>[];
    final today = DateTime(now.year, now.month, now.day);
    for (var offset = 1; offset <= 21; offset += 1) {
      final date = today.subtract(Duration(days: offset));
      for (final weeklyClass in weeklyClasses) {
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
