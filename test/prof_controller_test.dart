import 'package:flutter_test/flutter_test.dart';
import 'package:prof/data/prof_repository.dart';
import 'package:prof/domain/models.dart';
import 'package:prof/ui/prof_controller.dart';

void main() {
  test('cadastro edita turma, periodo, aluno, foto e grade semanal', () async {
    final controller = ProfController(
      repository: InMemoryProfRepository(),
      now: DateTime(2026, 5, 21, 19),
    );
    await controller.load();
    await controller.completeOnboarding(
      turma: 'DS3',
      periodo: '2026/1',
      disciplina: 'PAM2',
      alunos: 'Bruno Costa',
    );

    final group = controller.data.classGroups.single;
    final term = controller.term(group.termId);
    await controller.updateClassGroup(
      classGroupId: group.id,
      name: 'DS3 Noite',
      termName: '2026/1 noite',
      termStartDate: DateTime(2026, 2, 1),
      termEndDate: DateTime(2026, 6, 30),
    );
    await controller.addStudent(group.id, 'Ana Silva');
    final ana = controller
        .studentsForClass(group.id)
        .firstWhere((student) => student.name == 'Ana Silva');
    await controller.saveStudentPhotoBase64(ana, 'foto-base64');

    expect(controller.classGroup(group.id).name, 'DS3 Noite');
    expect(controller.term(term.id).name, '2026/1 noite');
    expect(controller.term(term.id).startDate, DateTime(2026, 2, 1));
    expect(controller.term(term.id).endDate, DateTime(2026, 6, 30));
    expect(
      controller.studentsForClass(group.id).map((student) => student.name),
      ['Ana Silva', 'Bruno Costa'],
    );
    expect(
      controller
          .studentsForClass(group.id)
          .firstWhere((student) => student.name == 'Ana Silva')
          .photoBase64,
      'foto-base64',
    );

    final weeklyClass = controller.data.weeklyClasses.single;
    await controller.updateWeeklyClass(
      id: weeklyClass.id,
      classGroupId: group.id,
      disciplineId: controller.data.disciplines.single.id,
      weekday: DateTime.friday,
      startMinutes: 20 * 60,
      endMinutes: 21 * 60 + 40,
    );

    expect(controller.currentLesson(), isNull);

    final fridayController = ProfController(
      repository: InMemoryProfRepository(controller.data),
      now: DateTime(2026, 5, 22, 20, 30),
    );
    await fridayController.load();
    expect(fridayController.currentLesson(), isNotNull);

    await fridayController.removeWeeklyClass(weeklyClass.id);
    expect(fridayController.data.weeklyClasses, isEmpty);
  });

  test('chamada pendente, cancelada e percentual seguem o dominio', () async {
    final now = DateTime(2026, 5, 21, 19);
    final controller = ProfController(
      repository: InMemoryProfRepository(),
      now: now,
    );
    await controller.load();
    await controller.completeOnboarding(
      turma: 'DS3',
      periodo: '2026/1',
      disciplina: 'PAM2',
      alunos: 'Ana Silva\nBruno Costa',
    );

    final current = controller.currentLesson();
    expect(current, isNotNull);

    final attendance = await controller.startAttendance(current!);
    final ana = controller
        .studentsForClass(current.weeklyClass.classGroupId)
        .first;
    await controller.markStudent(attendance, ana.id, AttendanceStatus.late);
    await controller.closeAttendance(controller.attendanceFor(current.id)!);

    final summaries = controller.summaries();
    expect(
      summaries
          .firstWhere((item) => item.student.name == 'Ana Silva')
          .presencePercent,
      100,
    );
    expect(
      summaries
          .firstWhere((item) => item.student.name == 'Bruno Costa')
          .presencePercent,
      0,
    );

    final csv = controller.csvExport();
    expect(csv, contains('Aluno,Turma,Disciplina,Periodo letivo'));
    expect(csv, contains('Ana Silva,DS3,PAM2,2026/1,1,0,1,0,0,100%'));

    final pendingController = ProfController(
      repository: InMemoryProfRepository(controller.data),
      now: DateTime(2026, 5, 28, 19),
    );
    await pendingController.load();
    expect(pendingController.pendingLessons(), isNotEmpty);

    final pending = pendingController.pendingLessons().first;
    await pendingController.cancelLesson(pending);
    expect(
      pendingController.pendingLessons().map((lesson) => lesson.id),
      isNot(contains(pending.id)),
    );
  });
}
