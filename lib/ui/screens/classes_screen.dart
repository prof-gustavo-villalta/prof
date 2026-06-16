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
                text:
                    'Nenhuma Turma cadastrada. Toque em Adicionar Turma para comeÃ§ar.',
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

                    return _ClassGroupListItem(
                      groupName: group.name,
                      termName: term.name,
                      studentCount: studentCount,
                      isLast: isLast,
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
                    );
                  },
                ),
          ],
        );
      },
    );
  }
}

class _ClassGroupListItem extends StatelessWidget {
  const _ClassGroupListItem({
    required this.groupName,
    required this.termName,
    required this.studentCount,
    required this.isLast,
    required this.onTap,
  });

  final String groupName;
  final String termName;
  final int studentCount;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedTapScale(
      onTap: onTap,
      child: BorderedContainer(
        isLast: isLast,
        sideBorders: true,
        padding: AppSpacing.compactRow,
        child: Row(
          children: [
            Expanded(
              flex: 70,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: AppTextStyles.rowTitle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      termName.toUpperCase(),
                      style: AppTextStyles.rowMeta.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  AppIconButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
