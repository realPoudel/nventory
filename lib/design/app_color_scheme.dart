import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material Design 3 color schemes for nVentory using Green Olive palette.
class AppColorScheme {
  AppColorScheme._();

  /// Light theme color scheme (MD3 full tonal hierarchy from seed #6B8E23)
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    // Primary tonal pair
    primary: AppColors.primaryGreen,               // #4C662B
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainerLight,  // #CDEDA3
    onPrimaryContainer: AppColors.onPrimaryContainerLight, // #102000
    // Secondary tonal pair
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLightest,
    onSecondaryContainer: AppColors.primaryGreenDark,
    // Tertiary tonal pair
    tertiary: AppColors.tertiaryGreen,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.secondaryLightest,
    onTertiaryContainer: AppColors.tertiaryMuted,
    // Error tonal pair
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.onError,
    onErrorContainer: AppColors.error,
    // Surface tonal hierarchy
    surface: AppColors.surfaceLight,
    onSurface: Color(0xFF1A1C18),
    surfaceDim: Color(0xFFDDD8D0),
    surfaceBright: AppColors.surfaceLight,
    surfaceContainerLow: Color(0xFFF6F3EE),
    surfaceContainer: AppColors.surfaceContainerLight,  // #F3F6EB
    surfaceContainerHigh: Color(0xFFEDE8E2),
    surfaceContainerHighest: AppColors.containerLight,
    // On-surface variant
    onSurfaceVariant: Color(0xFF49454F),
    // Outline tonal pair
    outline: AppColors.outlineLight,               // #75796C
    outlineVariant: Color(0xFFC5C5BA),
    // Inverse tonal pair
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: Color(0xFFE6E1E5),
    inversePrimary: AppColors.primaryGreenLight,    // #B2D189
    // Surface tint
    surfaceTint: AppColors.primaryGreen,
  );

  /// Dark theme color scheme (MD3 full tonal hierarchy from seed #6B8E23)
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    // Primary tonal pair
    primary: AppColors.primaryGreenLight,           // #B2D189
    onPrimary: Color(0xFF1F3701),
    primaryContainer: AppColors.primaryContainerDark,   // #354E16
    onPrimaryContainer: AppColors.onPrimaryContainerDark, // #CDEDA3
    // Secondary tonal pair
    secondary: AppColors.secondaryLighter,
    onSecondary: AppColors.primaryGreenDark,
    secondaryContainer: Color(0xFF2A3A1A),
    onSecondaryContainer: AppColors.secondaryLightest,
    // Tertiary tonal pair
    tertiary: AppColors.tertiaryGreen,
    onTertiary: Color(0xFF1A2E00),
    tertiaryContainer: Color(0xFF2A3A1A),
    onTertiaryContainer: AppColors.tertiaryGreen,
    // Error tonal pair
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    // Surface tonal hierarchy
    surface: AppColors.surfaceDark,
    onSurface: Color(0xFFE6E1E5),
    surfaceDim: Color(0xFF10140D),
    surfaceBright: Color(0xFF2A2E24),
    surfaceContainerLow: Color(0xFF151912),
    surfaceContainer: AppColors.surfaceContainerDark,   // #1D2118
    surfaceContainerHigh: Color(0xFF252A20),
    surfaceContainerHighest: AppColors.containerDark,
    // On-surface variant
    onSurfaceVariant: Color(0xFFCAC4D0),
    // Outline tonal pair
    outline: AppColors.outlineDark,
    outlineVariant: Color(0xFF4A4A3E),
    // Inverse tonal pair
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.surfaceLight,
    onInverseSurface: Color(0xFF1A1C18),
    inversePrimary: AppColors.primaryGreen,          // #4C662B
    // Surface tint
    surfaceTint: AppColors.primaryGreenLight,
  );
}
