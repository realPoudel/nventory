// Color scheme roles for nVentory using Green Olive palette
import 'package:flutter/material.dart';

/// Green Olive color scheme for the entire app.
/// Primary: Deep olive green for key actions and branding
/// Secondary: Light green for supportive elements
/// Tertiary: Muted green for accents
class AppColors {
  AppColors._();

  // === Primary Greens ===
  static const Color primaryGreen = Color(0xFF556B2F);       // Dark Olive
  static const Color primaryGreenLight = Color(0xFF6B8E23);  // Olive Drab
  static const Color primaryGreenDark = Color(0xFF3B4A1F);   // Deep Olive

  // === Secondary (Light Greens) ===
  static const Color secondaryLight = Color(0xFF8FBC8F);     // Dark Sea Green
  static const Color secondaryLighter = Color(0xFFB8D8B8);   // Light Sage
  static const Color secondaryLightest = Color(0xFFE8F5E9);  // Mint Cream

  // === Tertiary (Accent Greens) ===
  static const Color tertiaryGreen = Color(0xFF9ACD32);      // Yellow Green
  static const Color tertiaryMuted = Color(0xFF808000);      // Olive

  // === Surface & Container ===
  static const Color surfaceLight = Color(0xFFFAFAF5);
  static const Color surfaceDark = Color(0xFF1A1C18);
  static const Color containerLight = Color(0xFFF0F0EB);
  static const Color containerDark = Color(0xFF2A2C26);

  // === Outline ===
  static const Color outlineLight = Color(0xFFC5C5B8);
  static const Color outlineDark = Color(0xFF4A4A3E);

  // === Error & Success ===
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFCDD2);
  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFC8E6C9);
}
