import 'package:flutter/material.dart';
import '../prof_controller.dart';
import '../design_system/app_colors.dart';
import '../widgets/bordered_container.dart';
import '../widgets/page_header.dart';
import '../widgets/shared_ui.dart';
import '../widgets/student_avatar.dart';

class StudentSummaryScreen extends StatelessWidget {
  const StudentSummaryScreen({
    super.key,
    required this.controller,
    this.classGroupId,
    this.disciplineId,
  });

  final ProfController controller;
  final String? classGroupId;
  final String? disciplineId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final summaries = controller.summaries(
          classGroupId: classGroupId,
          disciplineId: disciplineId,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Resumo por Aluno'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                const PageHeader(
                  title: 'Resumo por aluno',
                  icon: Icons.assessment_rounded,
                ),
                const SizedBox(height: 28),
                if (summaries.isEmpty)
                  const EmptyCard(
                    text: 'Nenhum dado disponível para o filtro selecionado.',
                    noSideBorders: true,
                  )
                else
                  for (final summaryEntry in summaries.indexed)
                    Builder(builder: (context) {
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
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 20,
                                            child: StudentAvatar(student: summary.student),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 80,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  summary.student.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${summary.classGroup.name} - ${summary.discipline.name}',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: StatBadge(
                                              label: 'P',
                                              value: summary.present,
                                              color: AppColors.present,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: StatBadge(
                                              label: 'A',
                                              value: summary.absent,
                                              color: AppColors.absent,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: StatBadge(
                                              label: 'T',
                                              value: summary.late,
                                              color: AppColors.lateColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
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
                              Container(width: 2, color: AppColors.slate950),
                              Expanded(
                                flex: 30,
                                child: Builder(
                                  builder: (context) {
                                    final rate = summary.presencePercent;
                                    final Color rateColor;
                                    final Color rateBg;
                                    if (rate >= 75) {
                                      rateColor = AppColors.present;
                                      rateBg = AppColors.present.withValues(alpha: 0.12);
                                    } else if (rate >= 50) {
                                      rateColor = AppColors.lateColor;
                                      rateBg = AppColors.lateColor.withValues(alpha: 0.12);
                                    } else {
                                      rateColor = AppColors.absent;
                                      rateBg = AppColors.absent.withValues(alpha: 0.12);
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: rateBg,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${summary.presencePercent}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
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
                    }),
              ],
            ),
          ),
        );
      },
    );
  }
}

