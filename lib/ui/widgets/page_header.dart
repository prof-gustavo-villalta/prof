import 'package:flutter/material.dart';
import '../design_system/app_sizes.dart';
import '../design_system/app_spacing.dart';

/// Cabeçalho padrão de página: título pesado + ícone à direita.
///
/// Usado em Turmas, Histórico, Ajustes, etc.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: AppSizes.pageIcon,
          ),
        ],
      ),
    );
  }
}
