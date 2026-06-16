import 'package:flutter/material.dart';

import '../../domain/diario_de_classe.dart';
import '../../domain/models.dart';
import '../design_system.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';
import '../widgets/student_avatar.dart';

class StudentSummaryScreen extends StatelessWidget {
  const StudentSummaryScreen({
    super.key,
    required this.diario,
    this.classGroupId,
    this.disciplineId,
  });

  final DiarioDeClasse diario;
  final String? classGroupId;
  final String? disciplineId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: diario,
      builder: (context, _) {
        final summaries = diario.summaries(
          classGroupId: classGroupId,
          disciplineId: disciplineId,
        );

        return SingleColumnScreen(
          appBarTitle: 'Resumo por Aluno',
          title: 'Resumo por aluno',
          icon: Icons.assessment_rounded,
          children: [
            if (summaries.isEmpty)
              const EmptyCard(
                text:
                    'Sem dados de Aluno para o filtro atual. Abra e feche uma Chamada.',
                noSideBorders: true,
              )
            else
              for (final summaryEntry in summaries.indexed)
                Builder(
                  builder: (context) {
                    final summary = summaryEntry.$2;
                    final isLast = summaryEntry.$1 == summaries.length - 1;
                    final presentStyle = resolveAttendanceStatusStyle(
                      AttendanceStatus.present,
                    );
                    final absentStyle = resolveAttendanceStatusStyle(
                      AttendanceStatus.absent,
                    );
                    final lateStyle = resolveAttendanceStatusStyle(
                      AttendanceStatus.late,
                    );
                    final justifiedStyle = resolveAttendanceStatusStyle(
                      AttendanceStatus.justified,
                    );
                    final rateStyle = resolveAttendanceStatusStyle(
                      switch (summary.presencePercent) {
                        >= 75 => AttendanceStatus.present,
                        >= 50 => AttendanceStatus.late,
                        _ => AttendanceStatus.absent,
                      },
                    );

                    return BorderedContainer(
                      isLast: isLast,
                      sideBorders: true,
                      padding: EdgeInsets.zero,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 70,
                              child: Padding(
                                padding: AppSpacing.panel,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 20,
                                          child: StudentAvatar(
                                            student: summary.student,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xl),
                                        Expanded(
                                          flex: 80,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                summary.student.name,
                                                style: AppTextStyles.titleMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.xxs,
                                              ),
                                              Text(
                                                '${summary.classGroup.name} - ${summary.discipline.name}',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    const _SectionTitle(text: 'Metricas'),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: StudentSummaryStatusChip(
                                            label: presentStyle.label,
                                            value: summary.present,
                                            color: presentStyle.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: StudentSummaryStatusChip(
                                            label: absentStyle.label,
                                            value: summary.absent,
                                            color: absentStyle.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: StudentSummaryStatusChip(
                                            label: lateStyle.label,
                                            value: summary.late,
                                            color: lateStyle.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: StudentSummaryStatusChip(
                                            label: justifiedStyle.label,
                                            value: summary.justified,
                                            color: justifiedStyle.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: StudentSummaryMetric(
                                            label: 'Chamadas',
                                            value: summary.calledLessons,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: AppSizes.divider,
                              color: AppColors.slate950,
                            ),
                            Expanded(
                              flex: 30,
                              child: StudentSummaryRate(
                                percent: summary.presencePercent,
                                color: rateStyle.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.rowKicker.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

class StudentSummaryStatusChip extends StatelessWidget {
  const StudentSummaryStatusChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        textAlign: TextAlign.center,
        style: AppTextStyles.badge.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class StudentSummaryMetric extends StatelessWidget {
  const StudentSummaryMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppBorders.radius,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.badgeDot,
            height: AppSizes.badgeDot,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$label: $value',
              style: AppTextStyles.badge.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class StudentSummaryRate extends StatelessWidget {
  const StudentSummaryRate({
    super.key,
    required this.percent,
    required this.color,
  });

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border(left: BorderSide(color: color.withValues(alpha: 0.3))),
      ),
      child: Text(
        '$percent%',
        style: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
