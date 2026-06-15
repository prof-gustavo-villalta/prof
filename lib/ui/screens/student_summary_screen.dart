import 'package:flutter/material.dart';

import '../../domain/diario_de_classe.dart';
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
                text: 'Nenhum dado disponível para o filtro selecionado.',
                noSideBorders: true,
              )
            else
              for (final summaryEntry in summaries.indexed)
                Builder(
                  builder: (context) {
                    final summary = summaryEntry.$2;
                    final isLast = summaryEntry.$1 == summaries.length - 1;

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
                                    const SizedBox(height: AppSpacing.xl),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: StatBadge(
                                            label: 'P',
                                            value: summary.present,
                                            color: AppColors.present,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: StatBadge(
                                            label: 'A',
                                            value: summary.absent,
                                            color: AppColors.absent,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: StatBadge(
                                            label: 'T',
                                            value: summary.late,
                                            color: AppColors.lateColor,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: StatBadge(
                                            label: 'J',
                                            value: summary.justified,
                                            color: AppColors.justified,
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
                              child: Builder(
                                builder: (context) {
                                  final rate = summary.presencePercent;
                                  final Color rateColor;
                                  final Color rateBg;
                                  if (rate >= 75) {
                                    rateColor = AppColors.present;
                                    rateBg = AppColors.present.withValues(
                                      alpha: 0.12,
                                    );
                                  } else if (rate >= 50) {
                                    rateColor = AppColors.lateColor;
                                    rateBg = AppColors.lateColor.withValues(
                                      alpha: 0.12,
                                    );
                                  } else {
                                    rateColor = AppColors.absent;
                                    rateBg = AppColors.absent.withValues(
                                      alpha: 0.12,
                                    );
                                  }
                                  return Container(
                                    decoration: BoxDecoration(color: rateBg),
                                    child: Center(
                                      child: Text(
                                        '${summary.presencePercent}%',
                                        style: AppTextStyles.titleLarge
                                            .copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: rateColor,
                                            ),
                                      ),
                                    ),
                                  );
                                },
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
