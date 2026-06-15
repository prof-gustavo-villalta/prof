import 'models.dart';

class AttendanceReporter {
  const AttendanceReporter();

  List<AttendanceSummary> summaries(
    ProfData data, {
    String? classGroupId,
    String? disciplineId,
  }) {
    final result = <AttendanceSummary>[];
    final closed = data.attendances.where((attendance) => attendance.isClosed);
    for (final student in data.students) {
      for (final weeklyClass in data.weeklyClasses.where(
        (item) =>
            item.classGroupId == student.classGroupId &&
            (classGroupId == null || item.classGroupId == classGroupId) &&
            (disciplineId == null || item.disciplineId == disciplineId),
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

        final group = data.classGroups.firstWhere(
          (item) => item.id == weeklyClass.classGroupId,
        );
        final discipline = data.disciplines.firstWhere(
          (item) => item.id == weeklyClass.disciplineId,
        );
        final term = data.terms.firstWhere((item) => item.id == group.termId);

        result.add(
          AttendanceSummary(
            student: student,
            classGroup: group,
            discipline: discipline,
            term: term,
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

  String csvExport(
    ProfData data, {
    String? classGroupId,
    String? disciplineId,
  }) {
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
      for (final summary in summaries(
        data,
        classGroupId: classGroupId,
        disciplineId: disciplineId,
      ))
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

  List<ClosedAttendanceView> closedAttendanceViews(ProfData data) {
    final result = <ClosedAttendanceView>[];
    for (final attendance in data.attendances.where((item) => item.isClosed)) {
      final weeklyClass = data.weeklyClasses.firstWhere(
        (item) => item.id == attendance.weeklyClassId,
      );
      final group = data.classGroups.firstWhere(
        (item) => item.id == weeklyClass.classGroupId,
      );
      final disc = data.disciplines.firstWhere(
        (item) => item.id == weeklyClass.disciplineId,
      );
      result.add(
        ClosedAttendanceView(
          attendance: attendance,
          weeklyClass: weeklyClass,
          classGroup: group,
          discipline: disc,
        ),
      );
    }
    result.sort((a, b) => b.attendance.date.compareTo(a.attendance.date));
    return result;
  }

  String _csvCell(String value) {
    if (!value.contains(',') && !value.contains('"') && !value.contains('\n')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}
