import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../prof_controller.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
import 'discipline_form_screen.dart';
import 'schedule_form_screen.dart';

class ClassGroupScheduleScreen extends StatelessWidget {
  const ClassGroupScheduleScreen({
    super.key,
    required this.controller,
    required this.groupId,
  });

  final ProfController controller;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final group = controller.classGroup(groupId);
        final classes = controller.weeklyClasses
            .where((w) => w.classGroupId == groupId)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('Grade — ${group.name}'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      if (classes.isEmpty)
                        const EmptyCard(
                          text: 'Nenhum horário cadastrado.',
                          noSideBorders: true,
                        )
                      else
                        for (final entry in classes.indexed)
                          Builder(builder: (context) {
                            final weeklyClass = entry.$2;
                            final isLast = entry.$1 == classes.length - 1;
                            final discipline = controller.discipline(weeklyClass.disciplineId);
                            
                            return BorderedContainer(
                              isLast: isLast,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.slate950,
                                    ),
                                    child: Text(
                                      weekdayLabel(weeklyClass.weekday)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${group.name} - ${discipline.name}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${clock(weeklyClass.startMinutes)} - ${clock(weeklyClass.endMinutes)}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedTapScale(
                                    key: ValueKey(
                                      'edit_schedule_${discipline.name}',
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ScheduleFormScreen(
                                            controller: controller,
                                            weeklyClass: weeklyClass,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.slate950,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.tune_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                        child: AppButton(
                          text: 'Nova Disciplina',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.slate950,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DisciplineFormScreen(
                                  controller: controller,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(width: 2, color: AppColors.slate950),
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
                                  controller: controller,
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

