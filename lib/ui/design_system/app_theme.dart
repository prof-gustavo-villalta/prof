import 'package:flutter/material.dart';

import 'app_borders.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.white,
            onSurface: AppColors.slate950,
            error: AppColors.absent,
            outlineVariant: AppColors.slate200,
          ),
      scaffoldBackgroundColor: AppColors.slate50,
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.transparent,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.radius,
          side: AppBorders.strongSide,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.radius,
          side: AppBorders.strongSide,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.gutter,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorders.radius,
          borderSide: AppBorders.strongSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.radius,
          borderSide: AppBorders.subtleSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.radius,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppSizes.accentDivider,
          ),
        ),
        labelStyle: TextStyle(
          color: AppColors.slate500,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: AppBorders.shape,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.loose,
            vertical: AppSpacing.gutter,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.slate950,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorders.radius,
            side: AppBorders.strongSide,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.loose,
            vertical: AppSpacing.gutter,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: AppBorders.shape,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.slate50,
        foregroundColor: AppColors.slate950,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),
      iconTheme: const IconThemeData(color: AppColors.slate500, size: 24),
    );
  }
}
