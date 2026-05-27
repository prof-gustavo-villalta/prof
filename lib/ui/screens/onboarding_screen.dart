import 'package:flutter/material.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/shared_ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.diario});

  final DiarioDeClasse diario;

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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: theme.colorScheme.primary, width: 2.0),
                    ),
                    child: Icon(
                      Icons.hub_rounded,
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Primeira turma',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure o mínimo para abrir a chamada.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Field(
                          label: 'Turma (ex: DS3)',
                          controller: turma,
                          keyName: 'onboarding_turma',
                        ),
                        const SizedBox(height: 4),
                        Field(
                          label: 'Período letivo (ex: 2026/1)',
                          controller: periodo,
                          keyName: 'onboarding_periodo',
                        ),
                        const SizedBox(height: 4),
                        Field(
                          label: 'Disciplina (ex: PAM2)',
                          controller: disciplina,
                          keyName: 'onboarding_disciplina',
                        ),
                        const SizedBox(height: 4),
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
                const SizedBox(height: 24),
                AppButton(
                  key: const ValueKey('onboarding_submit'),
                  text: 'Começar',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => widget.diario.completeOnboarding(
                    turma: turma.text,
                    periodo: periodo.text,
                    disciplina: disciplina.text,
                    alunos: alunos.text,
                    now: DateTime.now(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
