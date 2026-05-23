import 'models.dart';

class LessonOccurrenceResolver {
  const LessonOccurrenceResolver();

  bool isCancelled(ProfData data, String lessonId) {
    return data.cancelledLessons.any((item) => item.lessonId == lessonId);
  }

  bool withinTerm(ProfData data, LessonOccurrence lesson) {
    final group = data.classGroups.firstWhere((item) => item.id == lesson.weeklyClass.classGroupId);
    final currentTerm = data.terms.firstWhere((item) => item.id == group.termId);
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

  LessonOccurrence? currentLesson(ProfData data, DateTime now) {
    for (final weeklyClass in data.weeklyClasses) {
      final occurrence = LessonOccurrence(weeklyClass: weeklyClass, date: now);
      if (weeklyClass.weekday == now.weekday &&
          !isCancelled(data, occurrence.id) &&
          !now.isBefore(occurrence.start) &&
          now.isBefore(occurrence.end) &&
          withinTerm(data, occurrence)) {
        return occurrence;
      }
    }
    return null;
  }

  LessonOccurrence? nextLesson(ProfData data, DateTime now) {
    LessonOccurrence? next;
    for (var offset = 0; offset < 21; offset += 1) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: offset));
      for (final weeklyClass in data.weeklyClasses) {
        if (weeklyClass.weekday != date.weekday) {
          continue;
        }
        final occurrence = LessonOccurrence(
          weeklyClass: weeklyClass,
          date: date,
        );
        if (isCancelled(data, occurrence.id) || !withinTerm(data, occurrence)) {
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

  List<LessonOccurrence> todaysLessons(ProfData data, DateTime now) {
    final lessons =
        data.weeklyClasses
            .where((weeklyClass) => weeklyClass.weekday == now.weekday)
            .map(
              (weeklyClass) =>
                  LessonOccurrence(weeklyClass: weeklyClass, date: now),
            )
            .where((lesson) => !isCancelled(data, lesson.id) && withinTerm(data, lesson))
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return lessons;
  }

  List<LessonOccurrence> pendingLessons(ProfData data, DateTime now) {
    final pending = <LessonOccurrence>[];
    final today = DateTime(now.year, now.month, now.day);
    for (var offset = 1; offset <= 21; offset += 1) {
      final date = today.subtract(Duration(days: offset));
      for (final weeklyClass in data.weeklyClasses) {
        if (weeklyClass.weekday != date.weekday) {
          continue;
        }
        final occurrence = LessonOccurrence(
          weeklyClass: weeklyClass,
          date: date,
        );
        if (isCancelled(data, occurrence.id) || !withinTerm(data, occurrence)) {
          continue;
        }
        final hasClosedAttendance = data.attendances.any(
          (attendance) => attendance.lessonId == occurrence.id && attendance.isClosed,
        );
        if (!hasClosedAttendance) {
          pending.add(occurrence);
        }
      }
    }
    pending.sort((a, b) => b.start.compareTo(a.start));
    return pending;
  }
}
