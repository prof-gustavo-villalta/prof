import 'package:flutter/material.dart';
import '../prof_controller.dart';
import '../widgets/animated_tap_scale.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ajustes', style: theme.textTheme.headlineMedium),
            Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 28),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedTapScale(
          onTap: () {
            controller.loadDemoData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Dados de demonstração carregados com sucesso!',
                  style: TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.inverseSurface,
              ),
            );
          },
          child: Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              title: Text(
                'Carregar dados demo',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Carrega turmas, disciplinas e alunos fictícios para demonstração.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              onTap: null, // Handled by AnimatedTapScale parent
            ),
          ),
        ),
      ],
    );
  }
}
