import 'package:flutter/material.dart';

import '../design_system.dart';

/// Dropdown estilizado no padrão visual do app.
///
/// Elimina a repetição de [dropdownColor], [style] e [decoration]
/// idênticos em todas as telas.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: Theme.of(context).colorScheme.surface,
      style: AppTextStyles.support.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: 10,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
