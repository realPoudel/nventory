import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material Design 3 color schemes for nVentory using Green Olive palette.
class AppColorScheme {
  AppColorScheme._();

  /// Light theme color scheme
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryGreen,
    onPrimary: Colors.white,
    primaryContainer: AppColors.secondaryLighter,
    onPrimaryContainer: AppColors.primaryGreenDark,
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLightest,
    onSecondaryContainer: AppColors.primaryGreenDark,
    tertiary: AppColors.tertiaryGreen,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.secondaryLightest,
    onTertiaryContainer: AppColors.tertiaryMuted,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.onError,
    onErrorContainer: AppColors.error,
    surface: AppColors.surfaceLight,
    onSurface: Color(0xFF1A1C18),
    surfaceContainerHighest: AppColors.containerLight,
    onSurfaceVariant: Color(0xFF49454F),
    outline: AppColors.outlineLight,
    outlineVariant: Color(0xFFE0E0D8),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: Color(0xFFE6E1E5),
    inversePrimary: AppColors.primaryGreenLight,
    surfaceTint: AppColors.primaryGreen,
  );

  /// Dark theme color scheme
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryGreenLight,
    onPrimary: AppColors.primaryGreenDark,
    primaryContainer: AppColors.primaryGreenDark,
    onPrimaryContainer: AppColors.secondaryLighter,
    secondary: AppColors.secondaryLighter,
    onSecondary: AppColors.primaryGreenDark,
    secondaryContainer: Color(0xFF2A3A1A),
    onSecondaryContainer: AppColors.secondaryLightest,
    tertiary: AppColors.tertiaryGreen,
    onTertiary: Color(0xFF1A2E00),
    tertiaryContainer: Color(0xFF2A3A1A),
    onTertiaryContainer: AppColors.tertiaryGreen,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.surfaceDark,
    onSurface: Color(0xFFE6E1E5),
    surfaceContainerHighest: AppColors.containerDark,
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: AppColors.outlineDark,
    outlineVariant: Color(0xFF4A4A3E),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.surfaceLight,
    onInverseSurface: Color(0xFF1A1C18),
    inversePrimary: AppColors.primaryGreen,
    surfaceTint: AppColors.primaryGreenLight,
  );
}
