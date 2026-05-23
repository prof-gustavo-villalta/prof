import 'package:flutter_test/flutter_test.dart';
import 'package:prof/data/prof_repository.dart';
import 'package:prof/domain/models.dart';
import 'package:prof/ui/prof_controller.dart';

void main() {
  test('dados demo cobrem turma, disciplinas, grade e fotos mistas', () async {
    final controller = ProfController(
      repository: InMemoryProfRepository(),
      now: DateTime(2026, 5, 21, 19),
    );
    await controller.load();
    await controller.loadDemoData();
    final groupId = controller.data.classGroups.single.id;
    final pam2 = controller.data.disciplines.firstWhere(
      (discipline) => discipline.name == 'PAM2',
    );
    final web2 = controller.data.disciplines.firstWhere(
      (discipline) => discipline.name == 'WEB2',
    );
    final pam2Lesson = controller.currentLesson()!;
    final attendance = await controller.startAttendance(pam2Lesson);
    await controller.closeAttendance(attendance);
    await controller.addWeeklyClass(
      classGroupId: groupId,
      disciplineId: web2.id,
      weekday: DateTime.thursday,
      startMinutes: 21 * 60,
      endMinutes: 22 * 60,
    );
    final web2Controller = ProfController(
      repository: InMemoryProfRepository(controller.data),
      now: DateTime(2026, 5, 21, 21, 30),
    );
    await web2Controller.load();
    final web2Attendance = await web2Controller.startAttendance(
      web2Controller.currentLesson()!,
    );
    await web2Controller.closeAttendance(web2Attendance);

    expect(
      web2Controller.data.classGroups.map((group) => group.name),
      contains('DS3'),
    );
    expect(
      web2Controller.data.disciplines.map((discipline) => discipline.name),
      containsAll(['PAM2', 'WEB2']),
    );
    expect(web2Controller.currentLesson(), isNotNull);
    expect(web2Controller.nextLesson(), isNotNull);
    expect(
      web2Controller.data.students.any(
        (student) => student.photoBase64 != null,
      ),
      isTrue,
    );
    expect(
      web2Controller.data.students.any(
        (student) => student.photoBase64 == null,
      ),
      isTrue,
    );
    expect(
      web2Controller.csvExport(classGroupId: groupId, disciplineId: pam2.id),
      contains('PAM2'),
    );
    expect(
      web2Controller.csvExport(classGroupId: groupId, disciplineId: pam2.id),
      isNot(contains('WEB2')),
    );

    final loadedAgain = ProfController(
      repository: InMemoryProfRepository(web2Controller.data),
      now: DateTime(2026, 5, 21, 19),
    );
    await loadedAgain.load();
    await loadedAgain.loadDemoData();
    expect(loadedAgain.data.classGroups.length, 1);
  });

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

  test('chamada repara ids duplicados antes de marcar um aluno', () async {
    const term = Term(id: 'term-1', name: '2026/1');
    const group = ClassGroup(id: 'turma-1', name: 'DS3', termId: 'term-1');
    const discipline = Discipline(id: 'disciplina-1', name: 'PAM2');
    const weeklyClass = WeeklyClass(
      id: 'grade-1',
      weekday: DateTime.thursday,
      startMinutes: 19 * 60,
      endMinutes: 21 * 60,
      classGroupId: 'turma-1',
      disciplineId: 'disciplina-1',
    );
    final repository = InMemoryProfRepository(
      const ProfData(
        terms: [term],
        classGroups: [group],
        disciplines: [discipline],
        students: [
          Student(id: 'aluno-duplicado', classGroupId: 'turma-1', name: 'Ana'),
          Student(
            id: 'aluno-duplicado',
            classGroupId: 'turma-1',
            name: 'Bruno',
          ),
        ],
        weeklyClasses: [weeklyClass],
      ),
    );
    final controller = ProfController(
      repository: repository,
      now: DateTime(2026, 5, 21, 19, 30),
    );

    await controller.load();

    final students = controller.studentsForClass(group.id);
    expect(students.map((student) => student.id).toSet(), hasLength(2));

    final lesson = controller.currentLesson()!;
    final attendance = await controller.startAttendance(lesson);
    final ana = students.firstWhere((student) => student.name == 'Ana');
    final bruno = students.firstWhere((student) => student.name == 'Bruno');

    await controller.togglePresence(attendance, ana.id);

    final updated = controller.attendanceFor(lesson.id)!;
    expect(updated.statusByStudentId[ana.id], AttendanceStatus.present);
    expect(updated.statusByStudentId[bruno.id], AttendanceStatus.absent);
  });
}
