// Color scheme roles for nVentory using Green Olive palette
// Seed: #6B8E23 (Olive Drab) — MD3 tonal hierarchy per Color_Roles_Flutter_Guide
import 'package:flutter/material.dart';

/// Green Olive color scheme for the entire app.
///
/// Light mode hierarchy (seed #6B8E23):
///   primary        → #4C662B  (FABs, main action buttons, active states)
///   onPrimary      → #FFFFFF  (text/icons over primary)
///   primaryContainer → #CDEDA3 (chips, search bar highlights, accent banners)
///   onPrimaryContainer → #102000 (titles/labels inside primary containers)
///   surfaceContainer → #F3F6EB (card surfaces, sheets, system bars)
///   outline         → #75796C (input boundaries, borders, splitters)
///
/// Dark mode hierarchy:
///   primary        → #B2D189  (dominant elements in low light)
///   onPrimary      → #1F3701  (dark text over light primary blocks)
///   primaryContainer → #354E16 (subtle accent banners, structural layouts)
///   onPrimaryContainer → #CDEDA3 (high readability on dark containers)
///   surfaceContainer → #1D2118 (dark theme card surfaces)
class AppColors {
  AppColors._();

  // === Seed Token (MD3 root) ===
  static const Color oliveSeed = Color(0xFF6B8E23);          // Olive Drab

  // === Primary Greens (Light: #4C662B / Dark: #B2D189) ===
  static const Color primaryGreen = Color(0xFF4C662B);        // MD3 Light primary
  static const Color primaryGreenLight = Color(0xFFB2D189);  // MD3 Dark primary
  static const Color primaryGreenDark = Color(0xFF102000);   // onPrimaryContainer (light)

  // === MD3 Primary Container ===
  static const Color primaryContainerLight = Color(0xFFCDEDA3);   // Light mode container
  static const Color primaryContainerDark = Color(0xFF354E16);    // Dark mode container
  static const Color onPrimaryContainerLight = Color(0xFF102000);  // Light mode contrast
  static const Color onPrimaryContainerDark = Color(0xFFCDEDA3);   // Dark mode contrast

  // === Secondary (Light Greens) ===
  static const Color secondaryLight = Color(0xFF8FBC8F);     // Dark Sea Green
  static const Color secondaryLighter = Color(0xFFB8D8B8);   // Light Sage
  static const Color secondaryLightest = Color(0xFFE8F5E9);  // Mint Cream

  // === Tertiary (Accent Greens) ===
  static const Color tertiaryGreen = Color(0xFF9ACD32);      // Yellow Green
  static const Color tertiaryMuted = Color(0xFF808000);      // Olive

  // === Surface & Container (Light: #F3F6EB / Dark: #1D2118) ===
  static const Color surfaceLight = Color(0xFFFAFAF5);
  static const Color surfaceDark = Color(0xFF1A1C18);
  static const Color surfaceContainerLight = Color(0xFFF3F6EB);  // MD3 spec
  static const Color surfaceContainerDark = Color(0xFF1D2118);   // MD3 spec
  static const Color containerLight = Color(0xFFF0F0EB);
  static const Color containerDark = Color(0xFF2A2C26);

  // === Outline (Light: #75796C / Dark: #4A4A3E) ===
  static const Color outlineLight = Color(0xFF75796C);       // MD3 spec
  static const Color outlineDark = Color(0xFF4A4A3E);

  // === Warning / Attention ===
  static const Color warning = Color(0xFFE6A817);           // Amber (MD3 warning)
  static const Color onWarning = Color(0xFFFFF8E1);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color onWarningContainer = Color(0xFF3E2723);

  // === Error & Success ===
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFCDD2);
  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFC8E6C9);
}
