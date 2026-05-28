import 'package:flutter/material.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';
import '../design_system/app_borders.dart';
import '../design_system/app_sizes.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.diario});

  final DiarioDeClasse diario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleColumnScreen(
      title: 'Ajustes',
      icon: Icons.tune_rounded,
      spacingAfterHeader: AppSpacing.page,
      children: [
        AnimatedTapScale(
          onTap: () {
            diario.loadDemoData(DateTime.now());
            showAppSnackBar(
              context,
              'Dados de demonstração carregados com sucesso!',
            );
          },
          child: Card(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.gutter,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.iconButton,
                    height: AppSizes.iconButton,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppBorders.radius,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: AppSizes.subtleDivider,
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: theme.colorScheme.primary,
                      size: AppSizes.infoIcon,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carregar dados demo',
                          style: AppTextStyles.rowTitle.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Carrega turmas, disciplinas e alunos fictícios para demonstração.',
                          style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
