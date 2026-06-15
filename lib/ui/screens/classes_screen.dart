import 'package:flutter/material.dart';

import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';
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

        return SingleColumnScreen(
          title: 'Turmas',
          icon: Icons.layers_rounded,
          paddingPreset: AppScreenPadding.list,
          spacingAfterHeader: AppSpacing.page,
          bottomActionBar: BottomActionBar(
            child: AppButton(
              text: 'Adicionar Turma',
              color: AppColors.primaryAction,
              height: AppSizes.actionHeight,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GroupFormScreen(diario: diario),
                  ),
                );
              },
            ),
          ),
          children: [
            if (groups.isEmpty)
              const EmptyCard(
                text: 'Nenhuma turma cadastrada.',
                noSideBorders: true,
              )
            else
              for (final entry in groups.indexed)
                Builder(
                  builder: (context) {
                    final group = entry.$2;
                    final isLast = entry.$1 == groups.length - 1;
                    final term = diario.term(group.termId);
                    final studentCount = diario
                        .studentsForClass(group.id)
                        .length;

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
                        padding: AppSpacing.row,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 20,
                              child: Text(
                                term.name.toUpperCase(),
                                style: AppTextStyles.rowKicker.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.md,
                                ),
                                child: Text(
                                  group.name,
                                  style: AppTextStyles.rowTitle.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
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
                                    style: AppTextStyles.rowMeta.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.4),
                                    size: 20,
                                  ),
                                ],
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
