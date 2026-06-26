import 'package:flutter/material.dart';
import 'app_color_scheme.dart';
import 'typography.dart';
/// Green Olive Material Design 3 theme configuration.
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData get light {
    const cs = AppColorScheme.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'OpenSans',
      // Typography — wires AppTextStyles into ThemeData so all widgets inherit
      textTheme: _buildTextTheme(cs, Brightness.light),
      primaryTextTheme: _buildTextTheme(cs, Brightness.light),
      // App bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: AppTextStyles.h4.copyWith(color: cs.onSurface),
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surfaceContainerHighest,
        surfaceTintColor: cs.surfaceTint,
      ),
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: cs.outline),
      ),
      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: AppTextStyles.h4.copyWith(color: cs.onSurface),
        contentTextStyle: AppTextStyles.body.copyWith(color: cs.onSurfaceVariant),
      ),
      // Navigation bar (mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium.copyWith(color: cs.onSurface);
          }
          return AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant);
        }),
      ),
      // Navigation rail (tablet/desktop)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        selectedIconTheme: IconThemeData(color: cs.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant),
        selectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(color: cs.onSurface),
        unselectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant),
      ),
      // Snack bar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
      ),
      // Progress indicator (circular + linear)
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        circularTrackColor: cs.surfaceContainerHighest,
        linearTrackColor: cs.surfaceContainerHighest,
        linearMinHeight: 4,
      ),
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.surfaceContainerHighest,
        thumbColor: cs.primary,
        overlayColor: cs.primary.withValues(alpha: 0.12),
        valueIndicatorColor: cs.primary,
        valueIndicatorTextStyle:
            AppTextStyles.labelSmall.copyWith(color: cs.onPrimary),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.onPrimary;
          }
          return cs.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.primary;
          }
          return cs.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.primary;
          }
          return cs.outline;
        }),
      ),
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle:
            AppTextStyles.bodySmall.copyWith(color: cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 500),
      ),
      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
      ),
      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        modalBarrierColor: cs.scrim.withValues(alpha: 0.5),
        showDragHandle: true,
        dragHandleColor: cs.onSurfaceVariant,
        dragHandleSize: const Size(32, 4),
      ),
      // List tile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTextStyles.body.copyWith(color: cs.onSurface),
        subtitleTextStyle:
            AppTextStyles.bodySmall.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }

  /// Dark theme
  static ThemeData get dark {
    const cs = AppColorScheme.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'OpenSans',
      // Typography — wires AppTextStyles into ThemeData so all widgets inherit
      textTheme: _buildTextTheme(cs, Brightness.dark),
      primaryTextTheme: _buildTextTheme(cs, Brightness.dark),
      // App bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: AppTextStyles.h4.copyWith(color: cs.onSurface),
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surfaceContainerHighest,
        surfaceTintColor: cs.surfaceTint,
      ),
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: cs.outline),
      ),
      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: AppTextStyles.h4.copyWith(color: cs.onSurface),
        contentTextStyle: AppTextStyles.body.copyWith(color: cs.onSurfaceVariant),
      ),
      // Navigation bar (mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium.copyWith(color: cs.onSurface);
          }
          return AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant);
        }),
      ),
      // Navigation rail (tablet/desktop)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        selectedIconTheme: IconThemeData(color: cs.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant),
        selectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(color: cs.onSurface),
        unselectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant),
      ),
      // Snack bar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
      ),
      // Progress indicator (circular + linear)
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        circularTrackColor: cs.surfaceContainerHighest,
        linearTrackColor: cs.surfaceContainerHighest,
        linearMinHeight: 4,
      ),
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.surfaceContainerHighest,
        thumbColor: cs.primary,
        overlayColor: cs.primary.withValues(alpha: 0.12),
        valueIndicatorColor: cs.primary,
        valueIndicatorTextStyle:
            AppTextStyles.labelSmall.copyWith(color: cs.onPrimary),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.onPrimary;
          }
          return cs.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.primary;
          }
          return cs.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.primary;
          }
          return cs.outline;
        }),
      ),
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle:
            AppTextStyles.bodySmall.copyWith(color: cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 500),
      ),
      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
      ),
      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        modalBarrierColor: cs.scrim.withValues(alpha: 0.5),
        showDragHandle: true,
        dragHandleColor: cs.onSurfaceVariant,
        dragHandleSize: const Size(32, 4),
      ),
      // List tile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTextStyles.body.copyWith(color: cs.onSurface),
        subtitleTextStyle:
            AppTextStyles.bodySmall.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }

  /// Builds a Material 3 TextTheme from AppTextStyles.
  /// Maps our custom styles to the 15 MD3 text roles so that any widget
  /// using `Theme.of(context).textTheme` inherits the Olive Green typography.
  static TextTheme _buildTextTheme(ColorScheme cs, Brightness brightness) {
    final Color onSurface = cs.onSurface;
    final Color onSurfaceVariant = cs.onSurfaceVariant;
    return TextTheme(
      // Display
      displayLarge: AppTextStyles.h1.copyWith(color: onSurface),
      displayMedium: AppTextStyles.h2.copyWith(color: onSurface),
      displaySmall: AppTextStyles.h3.copyWith(color: onSurface),
      // Headline
      headlineLarge: AppTextStyles.h2.copyWith(color: onSurface),
      headlineMedium: AppTextStyles.h3.copyWith(color: onSurface),
      headlineSmall: AppTextStyles.h4.copyWith(color: onSurface),
      // Title
      titleLarge: AppTextStyles.h4.copyWith(color: onSurface),
      titleMedium: AppTextStyles.bodyLarge.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      titleSmall: AppTextStyles.body.copyWith(color: onSurface, fontWeight: FontWeight.w500),
      // Body
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: onSurface),
      bodyMedium: AppTextStyles.body.copyWith(color: onSurface),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: onSurfaceVariant),
      // Label
      labelLarge: AppTextStyles.button.copyWith(color: onSurface),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: onSurfaceVariant),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: onSurfaceVariant),
    );
  }
}
