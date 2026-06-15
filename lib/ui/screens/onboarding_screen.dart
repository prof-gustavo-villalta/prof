import 'package:flutter/material.dart';

import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.diario, required this.now});

  final DiarioDeClasse diario;
  final DateTime now;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final turma = TextEditingController(text: 'DS3');
  final periodo = TextEditingController(text: '2026/1');
  final disciplina = TextEditingController(text: 'PAM2');
  final alunos = TextEditingController(text: 'Ana Silva\nBruno Costa');

  @override
  void dispose() {
    turma.dispose();
    periodo.dispose();
    disciplina.dispose();
    alunos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleColumnScreen(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.loose,
        vertical: AppSpacing.loose,
      ),
      children: [
        const SizedBox(height: AppSpacing.page),
        Center(
          child: Container(
            padding: AppSpacing.panel,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.rectangle,
              borderRadius: AppBorders.radius,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: AppSizes.divider,
              ),
            ),
            child: Icon(
              Icons.hub_rounded,
              size: AppSizes.heroIcon,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.gutter),
        Text(
          'Primeira turma',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Configure o mínimo para abrir a chamada.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.gutter),
        Card(
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Field(
                  label: 'Turma (ex: DS3)',
                  controller: turma,
                  keyName: 'onboarding_turma',
                ),
                const SizedBox(height: AppSpacing.xs),
                Field(
                  label: 'Período letivo (ex: 2026/1)',
                  controller: periodo,
                  keyName: 'onboarding_periodo',
                ),
                const SizedBox(height: AppSpacing.xs),
                Field(
                  label: 'Disciplina (ex: PAM2)',
                  controller: disciplina,
                  keyName: 'onboarding_disciplina',
                ),
                const SizedBox(height: AppSpacing.xs),
                MultilineField(
                  key: const ValueKey('onboarding_alunos'),
                  controller: alunos,
                  minLines: 2,
                  maxLines: 4,
                  label: 'Alunos, um por linha',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.loose),
        AppButton(
          key: const ValueKey('onboarding_submit'),
          text: 'Começar',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => widget.diario.completeOnboarding(
            turma: turma.text,
            periodo: periodo.text,
            disciplina: disciplina.text,
            alunos: alunos.text,
            now: widget.now,
          ),
        ),
      ],
    );
  }
}
