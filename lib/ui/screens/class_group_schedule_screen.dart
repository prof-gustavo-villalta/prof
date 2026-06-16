import 'package:flutter/material.dart';

import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';
import 'discipline_form_screen.dart';
import 'schedule_form_screen.dart';

class ClassGroupScheduleScreen extends StatelessWidget {
  const ClassGroupScheduleScreen({
    super.key,
    required this.diario,
    required this.groupId,
  });

  final DiarioDeClasse diario;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: diario,
      builder: (context, _) {
        final group = diario.classGroup(groupId);
        final classes = diario.weeklyClasses
            .where((w) => w.classGroupId == groupId)
            .toList();

        return SingleColumnScreen(
          appBarTitle: 'Grade Ã¢â‚¬â€ ${group.name}',
          title: 'Grade Semanal',
          icon: Icons.calendar_month_rounded,
          paddingPreset: AppScreenPadding.list,
          spacingAfterHeader: AppSpacing.xl,
          bottomActionBar: BottomSplitActionBar(
            left: AppButton(
              text: 'Adicionar disciplina',
              icon: Icons.menu_book_rounded,
              color: AppColors.slate950,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DisciplineFormScreen(diario: diario),
                  ),
                );
              },
            ),
            right: AppButton(
              text: 'Adicionar horário',
              icon: Icons.schedule_rounded,
              color: AppColors.primaryAction,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ScheduleFormScreen(diario: diario, groupId: groupId),
                  ),
                );
              },
            ),
          ),
          children: [
            if (classes.isEmpty)
              const EmptyCard(
                text:
                    'Nenhum Horario cadastrado na Grade Semanal. Toque em Adicionar Horario para iniciar.',
                noSideBorders: true,
              )
            else
              for (final entry in classes.indexed)
                Builder(
                  builder: (context) {
                    final weeklyClass = entry.$2;
                    final isLast = entry.$1 == classes.length - 1;
                    final discipline = diario.discipline(
                      weeklyClass.disciplineId,
                    );
                    final status = resolveLessonStatus(
                      LessonDisplayStatus.scheduled,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        border: Border(
                          top: AppBorders.strongSide,
                          bottom: isLast
                              ? AppBorders.strongSide
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: AppSpacing.compactRow,
                              child: LessonInfoRow(
                                statusLabel: status.label,
                                statusColor: status.color,
                                title:
                                    '${weekdayLabel(weeklyClass.weekday)} Â· ${group.name} - ${discipline.name}',
                                time:
                                    '${clock(weeklyClass.startMinutes)} - ${clock(weeklyClass.endMinutes)}',
                              ),
                            ),
                          ),
                          AppIconButton(
                            key: ValueKey('edit_schedule_${discipline.name}'),
                            icon: Icons.tune_rounded,
                            size: AppSizes.compactIconButton,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ScheduleFormScreen(
                                    diario: diario,
                                    weeklyClass: weeklyClass,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
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
