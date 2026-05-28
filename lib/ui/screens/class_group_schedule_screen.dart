import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_sizes.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_text_styles.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
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

        return Scaffold(
          appBar: AppBar(title: Text('Grade — ${group.name}')),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: AppSpacing.listVertical,
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
                                        weekdayLabel(
                                          weeklyClass.weekday,
                                        ).toUpperCase(),
                                        style: AppTextStyles.action.copyWith(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xl),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${group.name} - ${discipline.name}',
                                            style: AppTextStyles.rowTitle
                                                .copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.xxs,
                                          ),
                                          Text(
                                            '${clock(weeklyClass.startMinutes)} - ${clock(weeklyClass.endMinutes)}',
                                            style: AppTextStyles.caption
                                                .copyWith(
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
                                      key: ValueKey(
                                        'edit_schedule_${discipline.name}',
                                      ),
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
                  ),
                ),
                SizedBox(
                  height: AppSizes.actionHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 50,
                        child: AppButton(
                          text: 'Nova Disciplina',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.slate950,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    DisciplineFormScreen(diario: diario),
                              ),
                            );
                          },
                        ),
                      ),
                      const ActionDivider(),
                      Expanded(
                        flex: 50,
                        child: AppButton(
                          text: 'Novo Horário',
                          icon: Icons.schedule_rounded,
                          color: AppColors.primaryAction,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ScheduleFormScreen(
                                  diario: diario,
                                  groupId: groupId,
                                ),
                              ),
                            );
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
      },
    );
  }
}
