import 'package:flutter/material.dart';

import '../design_system.dart';

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
          Expanded(
            child: Text(
              title,
              style:
                  Theme.of(context).textTheme.titleLarge ??
                  AppTextStyles.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
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
