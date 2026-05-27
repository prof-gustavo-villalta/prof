import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
import 'class_group_detail_screen.dart';
import 'group_form_screen.dart';
class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key, required this.diario});

  final DiarioDeClasse diario;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: diario,
      builder: (context, _) {
        final groups = diario.classGroups;

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Turmas',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (groups.isEmpty)
                        const EmptyCard(
                          text: 'Nenhuma turma cadastrada.',
                          noSideBorders: true,
                        )
                      else
                        for (final entry in groups.indexed)
                          Builder(builder: (context) {
                            final group = entry.$2;
                            final isLast = entry.$1 == groups.length - 1;
                            final term = diario.term(group.termId);
                            final studentCount = diario.studentsForClass(group.id).length;
                            
                            return AnimatedTapScale(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ClassGroupDetailScreen(
                                      diario: diario,
                                      groupId: group.id,
                                    ),
                                  ),
                                );
                              },
                              child: BorderedContainer(
                                isLast: isLast,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 20,
                                      child: Text(
                                        term.name.toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Text(
                                          group.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 30,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$studentCount aluno${studentCount == 1 ? '' : 's'}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                            size: 20,
                                          ),
                                        ],
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
                SizedBox(
                  height: 66,
                  child: AppButton(
                    text: 'Adicionar Turma',
                    color: AppColors.primaryAction,
                    height: 66,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GroupFormScreen(
                            diario: diario,
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
    );
  }
}
