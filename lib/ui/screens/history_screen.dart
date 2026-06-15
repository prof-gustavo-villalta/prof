import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/shared_ui.dart';
import '../widgets/bordered_container.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/single_column_screen.dart';
import 'attendance_screen.dart';
import 'export_data_screen.dart';
import 'student_summary_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.diario});

  final DiarioDeClasse diario;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? classGroupId;
  String? disciplineId;

  @override
  Widget build(BuildContext context) {
    final selectedClassGroupId =
        classGroupId ?? widget.diario.classGroups.firstOrNull?.id;
    final selectedDisciplineId =
        disciplineId ?? widget.diario.disciplines.firstOrNull?.id;
    final closedAttendances = widget.diario.closedAttendanceViews();

    return SingleColumnScreen(
      title: 'Histórico',
      icon: Icons.insights_rounded,
      spacingAfterHeader: AppSpacing.page,
      bottomActionBar: BottomSplitActionBar(
        left: AppButton(
          text: 'Resumo',
          icon: Icons.assessment_rounded,
          color: AppColors.slate950,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StudentSummaryScreen(
                  diario: widget.diario,
                  classGroupId: selectedClassGroupId,
                  disciplineId: selectedDisciplineId,
                ),
              ),
            );
          },
        ),
        right: AppButton(
          text: 'Exportar CSV',
          icon: Icons.import_export_rounded,
          color: AppColors.primaryAction,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExportDataScreen(
                  diario: widget.diario,
                  classGroupId: selectedClassGroupId,
                  disciplineId: selectedDisciplineId,
                ),
              ),
            );
          },
        ),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: AppDropdown<String>(
                value: selectedClassGroupId,
                label: 'Turma',
                items: [
                  for (final group in widget.diario.classGroups)
                    DropdownMenuItem(value: group.id, child: Text(group.name)),
                ],
                onChanged: (value) => setState(() => classGroupId = value),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppDropdown<String>(
                value: selectedDisciplineId,
                label: 'Disciplina',
                items: [
                  for (final discipline in widget.diario.disciplines)
                    DropdownMenuItem(
                      value: discipline.id,
                      child: Text(discipline.name),
                    ),
                ],
                onChanged: (value) => setState(() => disciplineId = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.loose),
        if (closedAttendances.isEmpty)
          const EmptyCard(
            text: 'Nenhuma chamada fechada ainda.',
            noSideBorders: true,
          )
        else
          for (final entry in closedAttendances.indexed)
            Builder(
              builder: (context) {
                final view = entry.$2;
                final isLast = entry.$1 == closedAttendances.length - 1;

                return AnimatedTapScale(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AttendanceScreen(
                          diario: widget.diario,
                          lesson: LessonOccurrence(
                            weeklyClass: view.weeklyClass,
                            date: view.attendance.date,
                          ),
                          attendanceId: view.attendance.id,
                        ),
                      ),
                    );
                  },
                  child: BorderedContainer(
                    isLast: isLast,
                    padding: AppSpacing.panel,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${view.classGroup.name} - ${view.discipline.name}',
                                style: AppTextStyles.rowTitle.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                dateText(view.attendance.date),
                                style: AppTextStyles.caption.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}
