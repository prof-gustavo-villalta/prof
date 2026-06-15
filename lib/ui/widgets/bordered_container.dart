import 'package:flutter/material.dart';

import '../design_system.dart';

/// Container com bordas horizontais no estilo do app.
///
/// Usado para cards de lista, campos de busca, indicadores e filtros.
/// As bordas laterais podem ser omitidas via [sideBorders].
class BorderedContainer extends StatelessWidget {
  const BorderedContainer({
    super.key,
    required this.child,

    this.isLast = true,
    this.isFirst = true,
    this.sideBorders = false,
    this.backgroundColor,
    this.padding,
    this.height,
  });

  final Widget child;

  /// Ignorado — a borda superior é sempre aplicada.
  @Deprecated('Não tem efeito. A borda superior é sempre aplicada.')
  final bool isFirst;

  /// Se [true], aplica borda inferior (2px escura).
  final bool isLast;

  /// Se [true], também aplica bordas laterais (2px escura).
  final bool sideBorders;

  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardTheme.color,
        border: sideBorders
            ? AppBorders.horizontalWithSides(sideBorders: true)
            : AppBorders.bottomWhen(isLast),
      ),
      child: child,
    );
  }
}
