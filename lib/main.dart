import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'data/prof_repository.dart';
import 'domain/models.dart';
import 'ui/prof_controller.dart';

void main() {
  runApp(const ProfApp());
}

class ProfApp extends StatefulWidget {
  const ProfApp({super.key, ProfRepository? repository, this.now})
    : repository = repository ?? const SharedPreferencesProfRepository();

  final ProfRepository repository;
  final DateTime? now;

  @override
  State<ProfApp> createState() => _ProfAppState();
}

class _ProfAppState extends State<ProfApp> {
  late final ProfController controller;

  @override
  void initState() {
    super.initState();
    controller = ProfController(repository: widget.repository, now: widget.now)
      ..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prof',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E7CE2),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: Color(0xFFE8EBF0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDCE1EA)),
          ),
        ),
      ),
      home: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (!controller.isLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!controller.data.hasMinimumSetup) {
            return OnboardingScreen(controller: controller);
          }
          return HomeShell(controller: controller);
        },
      ),
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.controller});

  final ProfController controller;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(controller: controller),
      ClassesScreen(controller: controller),
      HistoryScreen(controller: controller),
      SettingsScreen(controller: controller),
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: pages[controller.selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.selectedIndex,
        onDestinationSelected: controller.selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            label: 'Hoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Turmas',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            label: 'Historico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final turma = TextEditingController(text: 'DS3');
  final periodo = TextEditingController(text: '2026/1');
  final disciplina = TextEditingController(text: 'PAM2');
  final alunos = TextEditingController(text: 'Ana Silva\nBruno Costa');

  @override
  void dispose() {
    turma.dispose();
    periodo.dispose();
    disciplina.dispose();
    alunos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 24),
                Text(
                  'Primeira turma',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure o minimo para abrir a chamada da aula certa.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _Field(
                  label: 'Turma',
                  controller: turma,
                  keyName: 'onboarding_turma',
                ),
                _Field(
                  label: 'Periodo letivo',
                  controller: periodo,
                  keyName: 'onboarding_periodo',
                ),
                _Field(
                  label: 'Disciplina',
                  controller: disciplina,
                  keyName: 'onboarding_disciplina',
                ),
                TextField(
                  key: const ValueKey('onboarding_alunos'),
                  controller: alunos,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Alunos, um por linha',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const ValueKey('onboarding_submit'),
                  onPressed: () => widget.controller.completeOnboarding(
                    turma: turma.text,
                    periodo: periodo.text,
                    disciplina: disciplina.text,
                    alunos: alunos.text,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Comecar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.currentLesson();
    final next = current ?? controller.nextLesson();
    final pending = controller.pendingLessons();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Hoje', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        if (next == null)
          const _EmptyCard(text: 'Nenhuma aula encontrada na Grade Semanal.')
        else
          LessonHeroCard(
            controller: controller,
            lesson: next,
            isCurrent: current != null,
          ),
        const SizedBox(height: 18),
        Text('Aulas do dia', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final lesson in controller.todaysLessons())
          LessonTile(controller: controller, lesson: lesson),
        const SizedBox(height: 18),
        Text('Pendentes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          const _EmptyCard(text: 'Nenhuma chamada pendente.')
        else
          for (final lesson in pending.take(10))
            LessonTile(controller: controller, lesson: lesson, pending: true),
      ],
    );
  }
}

class LessonHeroCard extends StatelessWidget {
  const LessonHeroCard({
    super.key,
    required this.controller,
    required this.lesson,
    required this.isCurrent,
  });

  final ProfController controller;
  final LessonOccurrence lesson;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final group = controller.classGroup(lesson.weeklyClass.classGroupId);
    final discipline = controller.discipline(lesson.weeklyClass.disciplineId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isCurrent ? 'Aula atual' : 'Proxima aula'),
            const SizedBox(height: 8),
            Text(
              '${group.name} - ${discipline.name}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(_lessonTime(lesson)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('start_attendance'),
                    onPressed: () async {
                      final attendance = await controller.startAttendance(
                        lesson,
                      );
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AttendanceScreen(
                            controller: controller,
                            lesson: lesson,
                            attendanceId: attendance.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text('Iniciar chamada'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Cancelar aula',
                  onPressed: () => controller.cancelLesson(lesson),
                  icon: const Icon(Icons.event_busy_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.controller,
    required this.lesson,
    this.pending = false,
  });

  final ProfController controller;
  final LessonOccurrence lesson;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final group = controller.classGroup(lesson.weeklyClass.classGroupId);
    final discipline = controller.discipline(lesson.weeklyClass.disciplineId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          title: Text('${group.name} - ${discipline.name}'),
          subtitle: Text(pending ? 'Chamada pendente' : _lessonTime(lesson)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final attendance = await controller.startAttendance(lesson);
            if (!context.mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AttendanceScreen(
                  controller: controller,
                  lesson: lesson,
                  attendanceId: attendance.id,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({
    super.key,
    required this.controller,
    required this.lesson,
    required this.attendanceId,
  });

  final ProfController controller;
  final LessonOccurrence lesson;
  final String attendanceId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final attendance = controller.data.attendances.firstWhere(
          (item) => item.id == attendanceId,
        );
        final group = controller.classGroup(lesson.weeklyClass.classGroupId);
        final discipline = controller.discipline(
          lesson.weeklyClass.disciplineId,
        );
        final students = controller.visibleAttendanceStudents(attendance);
        return Scaffold(
          appBar: AppBar(
            title: Text('${group.name} - ${discipline.name}'),
            actions: [
              if (attendance.isClosed)
                TextButton(
                  onPressed: () => controller.reopenAttendance(attendance),
                  child: const Text('Reabrir'),
                )
              else
                TextButton(
                  key: const ValueKey('close_attendance'),
                  onPressed: () async {
                    await controller.closeAttendance(attendance);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Fechar'),
                ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Buscar aluno',
                    ),
                    onChanged: controller.setStudentQuery,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final filter in const [
                        'Todos',
                        'Presentes',
                        'Ausentes',
                        'Atrasos',
                        'Justificados',
                      ])
                        ChoiceChip(
                          label: Text(filter),
                          selected: controller.statusFilter == filter,
                          onSelected: (_) => controller.setStatusFilter(filter),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final student in students)
                    StudentAttendanceCard(
                      controller: controller,
                      attendance: attendance,
                      student: student,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StudentAttendanceCard extends StatelessWidget {
  const StudentAttendanceCard({
    super.key,
    required this.controller,
    required this.attendance,
    required this.student,
  });

  final ProfController controller;
  final Attendance attendance;
  final Student student;

  @override
  Widget build(BuildContext context) {
    final status =
        attendance.statusByStudentId[student.id] ?? AttendanceStatus.absent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          key: ValueKey('student_${student.name}'),
          leading: StudentAvatar(student: student),
          title: Text(student.name),
          subtitle: Text(status.label),
          trailing: PopupMenuButton<AttendanceStatus>(
            onSelected: (value) =>
                controller.markStudent(attendance, student.id, value),
            itemBuilder: (context) => [
              for (final value in AttendanceStatus.values)
                PopupMenuItem(value: value, child: Text(value.label)),
            ],
          ),
          onTap: () => controller.togglePresence(attendance, student.id),
        ),
      ),
    );
  }
}

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final photo = student.photoBase64;
    return CircleAvatar(
      backgroundColor: const Color(0xFFE8ECFF),
      backgroundImage: photo == null ? null : MemoryImage(base64Decode(photo)),
      child: photo == null ? Text(student.initials) : null,
    );
  }
}

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final turma = TextEditingController();
  final periodo = TextEditingController(text: '2026/1');
  final disciplina = TextEditingController();
  final aluno = TextEditingController();
  final alunos = TextEditingController();
  final inicio = TextEditingController(text: '19:00');
  final fim = TextEditingController(text: '20:40');
  int weekday = DateTime.now().weekday;
  String? scheduleGroupId;
  String? scheduleDisciplineId;

  @override
  void dispose() {
    turma.dispose();
    periodo.dispose();
    disciplina.dispose();
    aluno.dispose();
    alunos.dispose();
    inicio.dispose();
    fim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstGroup = widget.controller.data.classGroups.firstOrNull;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Turmas', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        for (final group in widget.controller.data.classGroups)
          _GroupCard(controller: widget.controller, group: group),
        const SizedBox(height: 12),
        _ScheduleCard(
          controller: widget.controller,
          inicio: inicio,
          fim: fim,
          weekday: weekday,
          classGroupId: scheduleGroupId,
          disciplineId: scheduleDisciplineId,
          onWeekdayChanged: (value) => setState(() => weekday = value),
          onClassGroupChanged: (value) =>
              setState(() => scheduleGroupId = value),
          onDisciplineChanged: (value) =>
              setState(() => scheduleDisciplineId = value),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Nova turma',
          children: [
            _Field(label: 'Turma', controller: turma),
            _Field(label: 'Periodo letivo', controller: periodo),
            FilledButton(
              onPressed: () => widget.controller.addClassGroup(
                turma: turma.text,
                periodo: periodo.text,
              ),
              child: const Text('Adicionar turma'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Nova disciplina',
          children: [
            _Field(
              label: 'Disciplina',
              controller: disciplina,
              keyName: 'new_discipline_name',
            ),
            FilledButton(
              key: const ValueKey('add_discipline'),
              onPressed: () => widget.controller.addDiscipline(disciplina.text),
              child: const Text('Adicionar disciplina'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (firstGroup != null)
          _SectionCard(
            title: 'Adicionar alunos em ${firstGroup.name}',
            children: [
              _Field(
                label: 'Aluno',
                controller: aluno,
                keyName: 'single_student_name',
              ),
              FilledButton(
                key: const ValueKey('add_single_student'),
                onPressed: () =>
                    widget.controller.addStudent(firstGroup.id, aluno.text),
                child: const Text('Adicionar aluno'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alunos,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Um aluno por linha',
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () =>
                    widget.controller.addStudents(firstGroup.id, alunos.text),
                child: const Text('Adicionar alunos'),
              ),
            ],
          ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.controller,
    required this.inicio,
    required this.fim,
    required this.weekday,
    required this.classGroupId,
    required this.disciplineId,
    required this.onWeekdayChanged,
    required this.onClassGroupChanged,
    required this.onDisciplineChanged,
  });

  final ProfController controller;
  final TextEditingController inicio;
  final TextEditingController fim;
  final int weekday;
  final String? classGroupId;
  final String? disciplineId;
  final ValueChanged<int> onWeekdayChanged;
  final ValueChanged<String?> onClassGroupChanged;
  final ValueChanged<String?> onDisciplineChanged;

  @override
  Widget build(BuildContext context) {
    final groupId = classGroupId ?? controller.data.classGroups.firstOrNull?.id;
    final selectedDisciplineId =
        disciplineId ?? controller.data.disciplines.firstOrNull?.id;
    return _SectionCard(
      title: 'Grade Semanal',
      children: [
        for (final weeklyClass in controller.data.weeklyClasses)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${_weekdayLabel(weeklyClass.weekday)} - '
              '${controller.classGroup(weeklyClass.classGroupId).name} - '
              '${controller.discipline(weeklyClass.disciplineId).name}',
            ),
            subtitle: Text(
              '${_clock(weeklyClass.startMinutes)} - ${_clock(weeklyClass.endMinutes)}',
            ),
            trailing: IconButton(
              tooltip: 'Remover horario',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => controller.removeWeeklyClass(weeklyClass.id),
            ),
          ),
        const Divider(),
        DropdownButtonFormField<int>(
          initialValue: weekday,
          decoration: const InputDecoration(labelText: 'Dia da semana'),
          items: [
            for (var day = 1; day <= 7; day += 1)
              DropdownMenuItem(value: day, child: Text(_weekdayLabel(day))),
          ],
          onChanged: (value) {
            if (value != null) {
              onWeekdayChanged(value);
            }
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: const ValueKey('schedule_group'),
          initialValue: groupId,
          decoration: const InputDecoration(labelText: 'Turma'),
          items: [
            for (final group in controller.data.classGroups)
              DropdownMenuItem(value: group.id, child: Text(group.name)),
          ],
          onChanged: onClassGroupChanged,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: const ValueKey('schedule_discipline'),
          initialValue: selectedDisciplineId,
          decoration: const InputDecoration(labelText: 'Disciplina'),
          items: [
            for (final discipline in controller.data.disciplines)
              DropdownMenuItem(
                value: discipline.id,
                child: Text(discipline.name),
              ),
          ],
          onChanged: onDisciplineChanged,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Field(label: 'Inicio', controller: inicio),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Field(label: 'Fim', controller: fim),
            ),
          ],
        ),
        FilledButton.icon(
          key: const ValueKey('add_weekly_class'),
          onPressed: groupId == null || selectedDisciplineId == null
              ? null
              : () {
                  controller.addWeeklyClass(
                    classGroupId: groupId,
                    disciplineId: selectedDisciplineId,
                    weekday: weekday,
                    startMinutes: _parseClock(inicio.text),
                    endMinutes: _parseClock(fim.text),
                  );
                },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar horario'),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.controller, required this.group});

  final ProfController controller;
  final ClassGroup group;

  @override
  Widget build(BuildContext context) {
    final currentTerm = controller.term(group.termId);
    final students = controller.studentsForClass(group.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: Theme.of(context).textTheme.titleLarge),
              Text(currentTerm.name),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: ValueKey('edit_group_${group.name}'),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _EditGroupDialog(
                      controller: controller,
                      group: group,
                      term: currentTerm,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(height: 8),
              for (final student in students)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: StudentAvatar(student: student),
                  title: Text(student.name),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Camera',
                        onPressed: () => controller.pickStudentPhoto(
                          student,
                          ImageSource.camera,
                        ),
                        icon: const Icon(Icons.photo_camera_outlined),
                      ),
                      IconButton(
                        tooltip: 'Galeria ou upload',
                        onPressed: () => controller.pickStudentPhoto(
                          student,
                          ImageSource.gallery,
                        ),
                        icon: const Icon(Icons.upload_file_outlined),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditGroupDialog extends StatefulWidget {
  const _EditGroupDialog({
    required this.controller,
    required this.group,
    required this.term,
  });

  final ProfController controller;
  final ClassGroup group;
  final Term term;

  @override
  State<_EditGroupDialog> createState() => _EditGroupDialogState();
}

class _EditGroupDialogState extends State<_EditGroupDialog> {
  late final TextEditingController groupName;
  late final TextEditingController termName;
  late final TextEditingController startDate;
  late final TextEditingController endDate;

  @override
  void initState() {
    super.initState();
    groupName = TextEditingController(text: widget.group.name);
    termName = TextEditingController(text: widget.term.name);
    startDate = TextEditingController(text: _dateText(widget.term.startDate));
    endDate = TextEditingController(text: _dateText(widget.term.endDate));
  }

  @override
  void dispose() {
    groupName.dispose();
    termName.dispose();
    startDate.dispose();
    endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar turma'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Field(
              label: 'Turma',
              controller: groupName,
              keyName: 'edit_group_name',
            ),
            _Field(
              label: 'Periodo letivo',
              controller: termName,
              keyName: 'edit_term_name',
            ),
            _Field(
              label: 'Inicio opcional',
              controller: startDate,
              keyName: 'edit_term_start',
            ),
            _Field(
              label: 'Fim opcional',
              controller: endDate,
              keyName: 'edit_term_end',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('save_group'),
          onPressed: () async {
            await widget.controller.updateClassGroup(
              classGroupId: widget.group.id,
              name: groupName.text,
              termName: termName.text,
              termStartDate: _parseDate(startDate.text),
              termEndDate: _parseDate(endDate.text),
            );
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  Widget build(BuildContext context) {
    final summaries = controller.summaries();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Historico', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        if (summaries.isEmpty)
          const _EmptyCard(text: 'Nenhuma chamada fechada ainda.')
        else ...[
          for (final summary in summaries)
            Card(
              child: ListTile(
                title: Text(summary.student.name),
                subtitle: Text(
                  '${summary.classGroup.name} - ${summary.discipline.name}\n'
                  'Presencas ${summary.present} | Atrasos ${summary.late} | '
                  'Ausencias ${summary.absent} | Justificativas ${summary.justified}',
                ),
                trailing: Text('${summary.presencePercent}%'),
              ),
            ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'CSV',
            children: [
              FilledButton.icon(
                key: const ValueKey('copy_csv'),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV pronto para copiar')),
                  );
                  await Clipboard.setData(
                    ClipboardData(text: controller.csvExport()),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar CSV'),
              ),
              const SizedBox(height: 12),
              SelectableText(controller.csvExport()),
            ],
          ),
        ],
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ajustes', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Carregar dados demo'),
            subtitle: const Text('DS3, PAM2, WEB2 e alunos de exemplo.'),
            onTap: controller.loadDemoData,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.keyName});

  final String label;
  final TextEditingController controller;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: keyName == null ? null : ValueKey<String>(keyName!),
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(text)),
    );
  }
}

String _lessonTime(LessonOccurrence lesson) {
  return '${_clock(lesson.weeklyClass.startMinutes)} - ${_clock(lesson.weeklyClass.endMinutes)}';
}

String _clock(int minutes) {
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

int _parseClock(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    return 0;
  }
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return (hour.clamp(0, 23) * 60 + minute.clamp(0, 59)).toInt();
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    1 => 'Segunda',
    2 => 'Terca',
    3 => 'Quarta',
    4 => 'Quinta',
    5 => 'Sexta',
    6 => 'Sabado',
    _ => 'Domingo',
  };
}

DateTime? _parseDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return DateTime.tryParse(trimmed);
}

String _dateText(DateTime? date) {
  if (date == null) {
    return '';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
