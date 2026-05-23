import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models.dart';
import '../prof_controller.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/student_avatar.dart';
import '../widgets/shared_ui.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Turmas', style: Theme.of(context).textTheme.headlineMedium),
              Icon(Icons.hub_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          SectionCard(
            title: 'Nova turma',
            children: [
              Field(label: 'Turma', controller: turma),
              Field(label: 'Periodo letivo', controller: periodo),
              AppButton(
                text: 'Adicionar turma',
                onPressed: () {
                  widget.controller.addClassGroup(
                    turma: turma.text,
                    periodo: periodo.text,
                  );
                  turma.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Nova disciplina',
            children: [
              Field(
                label: 'Disciplina',
                controller: disciplina,
                keyName: 'new_discipline_name',
              ),
              AppButton(
                key: const ValueKey('add_discipline'),
                text: 'Adicionar disciplina',
                onPressed: () {
                  widget.controller.addDiscipline(disciplina.text);
                  disciplina.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (firstGroup != null)
            SectionCard(
              title: 'Adicionar alunos em ${firstGroup.name}',
              children: [
                Field(
                  label: 'Aluno',
                  controller: aluno,
                  keyName: 'single_student_name',
                ),
                AppButton(
                  key: const ValueKey('add_single_student'),
                  text: 'Adicionar aluno',
                  onPressed: () {
                    widget.controller.addStudent(firstGroup.id, aluno.text);
                    aluno.clear();
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alunos,
                  minLines: 3,
                  maxLines: 6,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    labelText: 'Um aluno por linha',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Adicionar alunos',
                  onPressed: () {
                    widget.controller.addStudents(firstGroup.id, alunos.text);
                    alunos.clear();
                  },
                ),
              ],
            ),
        ],
      ),
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
    return SectionCard(
      title: 'Grade Semanal',
      children: [
        if (controller.data.weeklyClasses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Nenhum horário cadastrado.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          for (final weeklyClass in controller.data.weeklyClasses)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        weekdayLabel(weeklyClass.weekday),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${controller.classGroup(weeklyClass.classGroupId).name} - ${controller.discipline(weeklyClass.disciplineId).name}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${clock(weeklyClass.startMinutes)} - ${clock(weeklyClass.endMinutes)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedTapScale(
                      key: ValueKey('edit_schedule_${controller.discipline(weeklyClass.disciplineId).name}'),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => _EditScheduleDialog(
                          controller: controller,
                          weeklyClass: weeklyClass,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: weekday,
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            labelText: 'Dia da semana',
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: [
            for (var day = 1; day <= 7; day += 1)
              DropdownMenuItem(value: day, child: Text(weekdayLabel(day))),
          ],
          onChanged: (value) {
            if (value != null) {
              onWeekdayChanged(value);
            }
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: const ValueKey('schedule_group'),
          value: groupId,
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            labelText: 'Turma',
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: [
            for (final group in controller.data.classGroups)
              DropdownMenuItem(value: group.id, child: Text(group.name)),
          ],
          onChanged: onClassGroupChanged,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: const ValueKey('schedule_discipline'),
          value: selectedDisciplineId,
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            labelText: 'Disciplina',
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: [
            for (final discipline in controller.data.disciplines)
              DropdownMenuItem(
                value: discipline.id,
                child: Text(discipline.name),
              ),
          ],
          onChanged: onDisciplineChanged,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Field(label: 'Inicio', controller: inicio),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Field(label: 'Fim', controller: fim),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppButton(
          key: const ValueKey('add_weekly_class'),
          text: 'Adicionar horario',
          icon: Icons.add_rounded,
          onPressed: groupId == null || selectedDisciplineId == null
              ? null
              : () {
                  controller.addWeeklyClass(
                    classGroupId: groupId,
                    disciplineId: selectedDisciplineId,
                    weekday: weekday,
                    startMinutes: parseClock(inicio.text),
                    endMinutes: parseClock(fim.text),
                  );
                },
        ),
      ],
    );
  }
}

class _EditScheduleDialog extends StatefulWidget {
  const _EditScheduleDialog({
    required this.controller,
    required this.weeklyClass,
  });

  final ProfController controller;
  final WeeklyClass weeklyClass;

  @override
  State<_EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<_EditScheduleDialog> {
  late final TextEditingController start;
  late final TextEditingController end;
  late int weekday;
  late String classGroupId;
  late String disciplineId;

  @override
  void initState() {
    super.initState();
    start = TextEditingController(
      text: clock(widget.weeklyClass.startMinutes),
    );
    end = TextEditingController(text: clock(widget.weeklyClass.endMinutes));
    weekday = widget.weeklyClass.weekday;
    classGroupId = widget.weeklyClass.classGroupId;
    disciplineId = widget.weeklyClass.disciplineId;
  }

  @override
  void dispose() {
    start.dispose();
    end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Editar horario',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: weekday,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Dia da semana',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              items: [
                for (var day = 1; day <= 7; day += 1)
                  DropdownMenuItem(value: day, child: Text(weekdayLabel(day))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => weekday = value);
                }
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: classGroupId,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Turma',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              items: [
                for (final group in widget.controller.data.classGroups)
                  DropdownMenuItem(value: group.id, child: Text(group.name)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => classGroupId = value);
                }
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: disciplineId,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Disciplina',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              items: [
                for (final discipline in widget.controller.data.disciplines)
                  DropdownMenuItem(
                    value: discipline.id,
                    child: Text(discipline.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => disciplineId = value);
                }
              },
            ),
            const SizedBox(height: 8),
            Field(
              label: 'Inicio',
              controller: start,
              keyName: 'edit_schedule_start',
            ),
            Field(
              label: 'Fim',
              controller: end,
              keyName: 'edit_schedule_end',
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: 120,
          child: HoldToConfirmButton(
            key: const ValueKey('delete_schedule'),
            text: 'Remover',
            baseColor: const Color(0xFF2C1616),
            fillColor: const Color(0xFFB91C1C),
            height: 48,
            onConfirmed: () async {
              await widget.controller.removeWeeklyClass(widget.weeklyClass.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        SizedBox(
          width: 120,
          child: AppButton(
            key: const ValueKey('save_schedule'),
            text: 'Salvar',
            height: 48,
            onPressed: () async {
              await widget.controller.updateWeeklyClass(
                id: widget.weeklyClass.id,
                classGroupId: classGroupId,
                disciplineId: disciplineId,
                weekday: weekday,
                startMinutes: parseClock(start.text),
                endMinutes: parseClock(end.text),
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentTerm.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedTapScale(
                    child: OutlinedButton.icon(
                      key: ValueKey('edit_group_${group.name}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => _EditGroupDialog(
                          controller: controller,
                          group: group,
                          term: currentTerm,
                        ),
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text(
                        'Editar',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 6),
              if (students.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Nenhum aluno cadastrado.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                )
              else
                for (final student in students)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        StudentAvatar(student: student),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            student.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        AnimatedTapScale(
                          onTap: () => _pickPhoto(
                            context,
                            controller,
                            student,
                            ImageSource.camera,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                            ),
                            child: Icon(
                              Icons.camera_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              size: 16,
                            ),
                          ),
                        ),
                        AnimatedTapScale(
                          onTap: () => _pickPhoto(
                            context,
                            controller,
                            student,
                            ImageSource.gallery,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              size: 16,
                            ),
                          ),
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

Future<void> _pickPhoto(
  BuildContext context,
  ProfController controller,
  Student student,
  ImageSource source,
) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: source, maxWidth: 1024);
  if (image == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto não alterada')),
      );
    }
    return;
  }
  final bytes = await image.readAsBytes();
  await controller.saveStudentPhotoBase64(student, base64Encode(bytes));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto atualizada')),
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
    startDate = TextEditingController(text: dateText(widget.term.startDate));
    endDate = TextEditingController(text: dateText(widget.term.endDate));
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
      title: const Text(
        'Editar turma',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Field(
              label: 'Turma',
              controller: groupName,
              keyName: 'edit_group_name',
            ),
            Field(
              label: 'Periodo letivo',
              controller: termName,
              keyName: 'edit_term_name',
            ),
            Field(
              label: 'Inicio opcional',
              controller: startDate,
              keyName: 'edit_term_start',
            ),
            Field(
              label: 'Fim opcional',
              controller: endDate,
              keyName: 'edit_term_end',
            ),
          ],
        ),
      ),
      actions: [
        AnimatedTapScale(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w800)),
          ),
        ),
        AppButton(
          key: const ValueKey('save_group'),
          text: 'Salvar',
          onPressed: () async {
            await widget.controller.updateClassGroup(
              classGroupId: widget.group.id,
              name: groupName.text,
              termName: termName.text,
              termStartDate: parseDate(startDate.text),
              termEndDate: parseDate(endDate.text),
            );
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
