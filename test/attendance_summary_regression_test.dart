import 'package:flutter_test/flutter_test.dart';
import 'package:prof/domain/attendance_reporter.dart';
import 'package:prof/domain/models.dart';

void main() {
  test('percentual e contagens dos resumos por aluno permanecem coerentes', () {
    final data = ProfData(
      terms: const [Term(id: 't-1', name: '2026')],
      classGroups: const [
        ClassGroup(id: 'g-1', name: 'Turma X', termId: 't-1'),
      ],
      disciplines: const [Discipline(id: 'd-1', name: 'Matemática')],
      students: const [
        Student(id: 's-ana', classGroupId: 'g-1', name: 'Ana'),
        Student(id: 's-bruno', classGroupId: 'g-1', name: 'Bruno'),
      ],
      weeklyClasses: const [
        WeeklyClass(
          id: 'w-1',
          weekday: DateTime.monday,
          startMinutes: 480,
          endMinutes: 540,
          classGroupId: 'g-1',
          disciplineId: 'd-1',
        ),
      ],
      attendances: [
        Attendance(
          id: 'a-1',
          lessonId: 'l-1',
          weeklyClassId: 'w-1',
          date: DateTime(2026, 6, 1),
          isClosed: true,
          statusByStudentId: {'s-ana': AttendanceStatus.present},
        ),
        Attendance(
          id: 'a-2',
          lessonId: 'l-2',
          weeklyClassId: 'w-1',
          date: DateTime(2026, 6, 2),
          isClosed: true,
          statusByStudentId: {'s-bruno': AttendanceStatus.late},
        ),
        Attendance(
          id: 'a-3',
          lessonId: 'l-3',
          weeklyClassId: 'w-1',
          date: DateTime(2026, 6, 3),
          isClosed: true,
          statusByStudentId: {
            's-ana': AttendanceStatus.justified,
            's-bruno': AttendanceStatus.absent,
          },
        ),
        Attendance(
          id: 'a-4',
          lessonId: 'l-4',
          weeklyClassId: 'w-1',
          date: DateTime(2026, 6, 4),
          isClosed: true,
          statusByStudentId: const {},
        ),
      ],
    );

    final reporter = const AttendanceReporter();
    final summaries = reporter.summaries(data);
    expect(summaries, hasLength(2));

    final anaSummary = summaries.singleWhere(
      (item) => item.student.id == 's-ana',
    );
    final brunoSummary = summaries.singleWhere(
      (item) => item.student.id == 's-bruno',
    );

    expect(anaSummary.calledLessons, equals(4));
    expect(anaSummary.present, equals(1));
    expect(anaSummary.late, equals(0));
    expect(anaSummary.absent, equals(2));
    expect(anaSummary.justified, equals(1));
    expect(anaSummary.presencePercent, equals(25));

    expect(brunoSummary.calledLessons, equals(4));
    expect(brunoSummary.present, equals(0));
    expect(brunoSummary.late, equals(1));
    expect(brunoSummary.absent, equals(3));
    expect(brunoSummary.justified, equals(0));
    expect(brunoSummary.presencePercent, equals(25));

    for (final summary in summaries) {
      final total =
          summary.present + summary.late + summary.absent + summary.justified;
      expect(summary.calledLessons, equals(total));
      if (summary.calledLessons == 0) {
        expect(summary.presencePercent, equals(0));
      } else {
        expect(
          summary.presencePercent,
          equals(
            ((summary.present + summary.late) / summary.calledLessons * 100)
                .round(),
          ),
        );
      }
    }

    final csv = reporter.csvExport(data);
    expect(csv, contains('Ana'));
    expect(csv, contains('Bruno'));
    expect(csv, contains('25%'));
  });
}
