import 'package:flutter/material.dart';

import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.diario});

  final DiarioDeClasse diario;

  @override
  Widget build(BuildContext context) {
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
              'Dados de Turma, Disciplina e Aluno demonstracao carregados com sucesso.',
            );
          },
          child: SectionCard(
            title: 'Carregar dados demo',
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizes.iconButton,
                    height: AppSizes.iconButton,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: AppBorders.radius,
                      border: Border.all(
                        color: AppColors.primaryAction,
                        width: AppSizes.subtleDivider,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primaryAction,
                      size: AppSizes.infoIcon,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: Text(
                      'Carrega Turma, Disciplina e Aluno ficticios para demonstracao.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.slate600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
