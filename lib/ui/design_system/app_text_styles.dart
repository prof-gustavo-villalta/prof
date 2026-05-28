import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const headlineMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    color: AppColors.slate950,
    height: 1.2,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
    color: AppColors.slate950,
    height: 1.25,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.slate950,
  );

  static const titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.slate950,
  );

  static const bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.slate600,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.slate600,
    height: 1.4,
  );

  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static const appBarTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.slate950,
    letterSpacing: -0.5,
  );

  static const rowKicker = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 13,
    letterSpacing: 0.5,
  );

  static const rowTitle = TextStyle(fontWeight: FontWeight.w800, fontSize: 15);
  static const rowMeta = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
  static const support = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
  static const badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
  );
  static const action = TextStyle(
    color: AppColors.white,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
  );
}
