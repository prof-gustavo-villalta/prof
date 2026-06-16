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
      isExpanded: true,
      dropdownColor: Theme.of(context).colorScheme.surface,
      style: AppTextStyles.support.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              alignment: item.alignment,
              onTap: item.onTap,
              child: _DropdownMenuItemLabel(child: item.child),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => items
          .map((item) => _DropdownMenuItemLabel(child: item.child))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DropdownMenuItemLabel extends StatelessWidget {
  const _DropdownMenuItemLabel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (child is Text) {
      final text = child as Text;
      return Text(
        text.data ?? '',
        style: text.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return child;
  }
}
