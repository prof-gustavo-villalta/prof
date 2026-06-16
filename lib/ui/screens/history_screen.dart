import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
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
  String statusFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final selectedClassGroupId =
        classGroupId ?? widget.diario.classGroups.firstOrNull?.id;
    final selectedDisciplineId =
        disciplineId ?? widget.diario.disciplines.firstOrNull?.id;

    final closedAttendances = widget.diario.closedAttendanceViews().where((
      view,
    ) {
      if (selectedClassGroupId != null &&
          view.classGroup.id != selectedClassGroupId) {
        return false;
      }
      if (selectedDisciplineId != null &&
          view.discipline.id != selectedDisciplineId) {
        return false;
      }
      return _matchesStatusFilter(view.attendance, statusFilter);
    }).toList();

    return SingleColumnScreen(
      title: 'HistÃ³rico',
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
        const SizedBox(height: AppSpacing.gutter),
        AppFilterRow(
          filters: const [
            'Todos',
            'Presentes',
            'Ausentes',
            'Atrasos',
            'Justificados',
          ],
          filterColors: {
            'Todos': AppColors.slate500,
            'Presentes': resolveAttendanceStatusStyle(
              AttendanceStatus.present,
            ).accentColor,
            'Ausentes': resolveAttendanceStatusStyle(
              AttendanceStatus.absent,
            ).accentColor,
            'Atrasos': resolveAttendanceStatusStyle(
              AttendanceStatus.late,
            ).accentColor,
            'Justificados': resolveAttendanceStatusStyle(
              AttendanceStatus.justified,
            ).accentColor,
          },
          selectedFilter: statusFilter,
          onSelected: (value) {
            setState(() {
              statusFilter = value;
            });
          },
        ),
        const SizedBox(height: AppSpacing.loose),
        if (closedAttendances.isEmpty)
          const EmptyCard(
            text:
                'Sem Chamada fechada ainda. Abra e feche uma Chamada para alimentar o Historico.',
            noSideBorders: true,
          )
        else
          for (final entry in closedAttendances.indexed)
            Builder(
              builder: (context) {
                final view = entry.$2;
                final isLast = entry.$1 == closedAttendances.length - 1;
                final statusCounts = _attendanceCounts(view.attendance);
                final summary = resolveLessonStatus(LessonDisplayStatus.closed);

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
                    sideBorders: true,
                    padding: AppSpacing.compactRow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LessonInfoRow(
                                statusLabel: summary.label,
                                statusColor: summary.color,
                                title:
                                    '${view.classGroup.name} - ${view.discipline.name}',
                                time:
                                    '${dateText(view.attendance.date)} - ${clock(view.weeklyClass.startMinutes)} - ${clock(view.weeklyClass.endMinutes)}',
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
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _HistoryStatusChip(
                                label: 'P',
                                count: statusCounts.present,
                                color: resolveAttendanceStatusStyle(
                                  AttendanceStatus.present,
                                ).accentColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: _HistoryStatusChip(
                                label: 'A',
                                count: statusCounts.absent,
                                color: resolveAttendanceStatusStyle(
                                  AttendanceStatus.absent,
                                ).accentColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: _HistoryStatusChip(
                                label: 'T',
                                count: statusCounts.late,
                                color: resolveAttendanceStatusStyle(
                                  AttendanceStatus.late,
                                ).accentColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: _HistoryStatusChip(
                                label: 'J',
                                count: statusCounts.justified,
                                color: resolveAttendanceStatusStyle(
                                  AttendanceStatus.justified,
                                ).accentColor,
                              ),
                            ),
                          ],
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

  ({int present, int late, int absent, int justified}) _attendanceCounts(
    Attendance attendance,
  ) {
    var present = 0;
    var late = 0;
    var absent = 0;
    var justified = 0;

    for (final status in attendance.statusByStudentId.values) {
      switch (status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.justified:
          justified++;
      }
    }

    return (present: present, late: late, absent: absent, justified: justified);
  }

  bool _matchesStatusFilter(Attendance attendance, String filter) {
    if (filter == 'Todos') {
      return true;
    }

    final counts = _attendanceCounts(attendance);
    return switch (filter) {
      'Presentes' => counts.present > 0,
      'Ausentes' => counts.absent > 0,
      'Atrasos' => counts.late > 0,
      'Justificados' => counts.justified > 0,
      _ => true,
    };
  }
}

class _HistoryStatusChip extends StatelessWidget {
  const _HistoryStatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorders.radius,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        '$label $count',
        textAlign: TextAlign.center,
        style: AppTextStyles.badge.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
