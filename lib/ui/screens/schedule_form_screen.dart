import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({
    super.key,
    required this.diario,
    this.weeklyClass,
    this.groupId,
  });

  final DiarioDeClasse diario;
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
    if (classGroupId == null && widget.diario.classGroups.isNotEmpty) {
      classGroupId = widget.diario.classGroups.first.id;
    }
    disciplineId = widget.weeklyClass?.disciplineId;
    if (disciplineId == null && widget.diario.disciplines.isNotEmpty) {
      disciplineId = widget.diario.disciplines.first.id;
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
    final title = isEditing ? 'Editar horário' : 'Novo horário';

    return SingleColumnScreen(
      appBarTitle: title,
      title: title,
      icon: isEditing ? Icons.edit_rounded : Icons.schedule_rounded,
      bottomActionBar: BottomSplitActionBar(
        left: isEditing
            ? HoldToConfirmButton(
                key: const ValueKey('delete_schedule'),
                text: 'Remover',
                baseColor: AppColors.cancelBase,
                fillColor: AppColors.cancelFill,
                onConfirmed: () async {
                  await widget.diario.removeWeeklyClass(widget.weeklyClass!.id);
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
        right: AppButton(
          key: const ValueKey('save_schedule'),
          text: 'Salvar',
          icon: Icons.check_rounded,
          color: AppColors.primaryAction,
          onPressed: () async {
            if (classGroupId == null || disciplineId == null) return;
            if (isEditing) {
              await widget.diario.updateWeeklyClass(
                id: widget.weeklyClass!.id,
                classGroupId: classGroupId!,
                disciplineId: disciplineId!,
                weekday: weekday,
                startMinutes: parseClock(start.text),
                endMinutes: parseClock(end.text),
              );
            } else {
              await widget.diario.addWeeklyClass(
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
      children: [
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
        const SizedBox(height: AppSpacing.md),
        AppDropdown<String>(
          value: classGroupId,
          label: 'Turma',
          items: [
            for (final group in widget.diario.classGroups)
              DropdownMenuItem(value: group.id, child: Text(group.name)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => classGroupId = value);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppDropdown<String?>(
          key: const ValueKey('schedule_discipline'),
          value: disciplineId,
          label: 'Disciplina',
          items: [
            if (widget.diario.disciplines.isEmpty)
              const DropdownMenuItem(
                value: null,
                child: Text('Nenhuma cadastrada'),
              ),
            for (final discipline in widget.diario.disciplines)
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
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Field(
                label: 'Inicio',
                controller: start,
                keyName: 'edit_schedule_start',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
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
    );
  }
}
