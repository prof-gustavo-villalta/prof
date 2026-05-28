import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

abstract final class AppBorders {
  static const radius = BorderRadius.zero;
  static const shape = RoundedRectangleBorder(borderRadius: radius);

  static const strongSide = BorderSide(
    color: AppColors.slate950,
    width: AppSizes.divider,
  );

  static const subtleSide = BorderSide(
    color: AppColors.slate200,
    width: AppSizes.subtleDivider,
  );

  static const strong = Border.fromBorderSide(strongSide);
  static const horizontal = Border(top: strongSide, bottom: strongSide);
  static const top = Border(top: strongSide);

  static Border bottomWhen(bool enabled) {
    return Border(
      top: strongSide,
      bottom: enabled ? strongSide : BorderSide.none,
    );
  }

  static Border horizontalWithSides({required bool sideBorders}) {
    return Border(
      top: strongSide,
      bottom: strongSide,
      left: sideBorders ? strongSide : BorderSide.none,
      right: sideBorders ? strongSide : BorderSide.none,
    );
  }
}
