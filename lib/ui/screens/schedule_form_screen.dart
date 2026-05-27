import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../prof_controller.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/page_header.dart';
import '../widgets/shared_ui.dart';

class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({
    super.key,
    required this.controller,
    this.weeklyClass,
    this.groupId,
  });

  final ProfController controller;
  final WeeklyClass? weeklyClass;
  final String? groupId;

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  late final TextEditingController start;
  late final TextEditingController end;
  late int weekday;
  late String? classGroupId;
  late String? disciplineId;

  bool get isEditing => widget.weeklyClass != null;

  @override
  void initState() {
    super.initState();
    start = TextEditingController(
      text: isEditing ? clock(widget.weeklyClass!.startMinutes) : '19:00',
    );
    end = TextEditingController(
      text: isEditing ? clock(widget.weeklyClass!.endMinutes) : '20:40',
    );
    weekday = widget.weeklyClass?.weekday ?? DateTime.now().weekday;
    classGroupId = widget.weeklyClass?.classGroupId ?? widget.groupId;
    if (classGroupId == null && widget.controller.classGroups.isNotEmpty) {
      classGroupId = widget.controller.classGroups.first.id;
    }
    disciplineId = widget.weeklyClass?.disciplineId;
    if (disciplineId == null && widget.controller.disciplines.isNotEmpty) {
      disciplineId = widget.controller.disciplines.first.id;
    }
  }

  @override
  void dispose() {
    start.dispose();
    end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar horário' : 'Novo horário'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  PageHeader(
                    title: isEditing ? 'Editar horário' : 'Novo horário',
                    icon: isEditing ? Icons.edit_rounded : Icons.schedule_rounded,
                  ),
                  const SizedBox(height: 28),
                  AppDropdown<int>(
                    value: weekday,
                    label: 'Dia da semana',
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
                  if (classGroupId != null)
                    AppDropdown<String>(
                      value: classGroupId,
                      label: 'Turma',
                      items: [
                        for (final group in widget.controller.classGroups)
                          DropdownMenuItem(value: group.id, child: Text(group.name)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => classGroupId = value);
                        }
                      },
                    ),
                  const SizedBox(height: 8),
                  if (disciplineId != null || widget.controller.disciplines.isEmpty)
                    AppDropdown<String?>(
                      value: disciplineId,
                      label: 'Disciplina',
                      items: [
                        if (widget.controller.disciplines.isEmpty)
                          const DropdownMenuItem(value: null, child: Text('Nenhuma cadastrada')),
                        for (final discipline in widget.controller.disciplines)
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
                  Row(
                    children: [
                      Expanded(
                        child: Field(
                          label: 'Inicio',
                          controller: start,
                          keyName: 'edit_schedule_start',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Field(
                          label: 'Fim',
                          controller: end,
                          keyName: 'edit_schedule_end',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 66,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 50,
                    child: isEditing
                        ? HoldToConfirmButton(
                            key: const ValueKey('delete_schedule'),
                            text: 'Remover',
                            baseColor: AppColors.cancelBase,
                            fillColor: AppColors.cancelFill,
                            onConfirmed: () async {
                              await widget.controller.removeWeeklyClass(widget.weeklyClass!.id);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          )
                        : AppButton(
                            text: 'Cancelar',
                            icon: Icons.close_rounded,
                            color: AppColors.slate950,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                  ),
                  Container(width: 2, color: AppColors.slate950),
                  Expanded(
                    flex: 50,
                    child: AppButton(
                      key: const ValueKey('save_schedule'),
                      text: 'Salvar',
                      icon: Icons.check_rounded,
                      color: AppColors.primaryAction,
                      onPressed: () async {
                        if (classGroupId == null || disciplineId == null) return;
                        if (isEditing) {
                          await widget.controller.updateWeeklyClass(
                            id: widget.weeklyClass!.id,
                            classGroupId: classGroupId!,
                            disciplineId: disciplineId!,
                            weekday: weekday,
                            startMinutes: parseClock(start.text),
                            endMinutes: parseClock(end.text),
                          );
                        } else {
                          widget.controller.addWeeklyClass(
                            classGroupId: classGroupId!,
                            disciplineId: disciplineId!,
                            weekday: weekday,
                            startMinutes: parseClock(start.text),
                            endMinutes: parseClock(end.text),
                          );
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
