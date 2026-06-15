import 'package:flutter/material.dart';

import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/bordered_container.dart';
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
          appBarTitle: 'Grade — ${group.name}',
          title: 'Grade Semanal',
          icon: Icons.calendar_month_rounded,
          paddingPreset: AppScreenPadding.list,
          spacingAfterHeader: AppSpacing.xl,
          bottomActionBar: BottomSplitActionBar(
            left: AppButton(
              text: 'Nova Disciplina',
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
              text: 'Novo Horário',
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
                text: 'Nenhum horário cadastrado.',
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

                    return BorderedContainer(
                      isLast: isLast,
                      padding: AppSpacing.compactRow,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.slate950,
                            ),
                            child: Text(
                              weekdayLabel(weeklyClass.weekday).toUpperCase(),
                              style: AppTextStyles.action.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${group.name} - ${discipline.name}',
                                  style: AppTextStyles.rowTitle.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  '${clock(weeklyClass.startMinutes)} - ${clock(weeklyClass.endMinutes)}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
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
