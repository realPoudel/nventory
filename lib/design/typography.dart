import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system for nVentory using Open Sans.
///
/// MD3 Typography Inheritance:
/// - [AppTextStyles] provides raw styles (font size/weight/height) without
///   color — used with `.copyWith(color: cs.onSurface)` for full control.
/// - [ThemedTextStyles] provides visibility-aware styles with theme colors
///   pre-applied — use directly for consistent text visibility in both
///   light and dark modes.
///
/// Font sizes per spec:
/// Headings: H1 40px, H2 32px, H3 28px, H4 24px
/// Body: Large 18px, Body 16px, Small 14px
/// Labels: Large 14px, Medium 12px, Small 11px
/// Others: Button 14px, Caption 12px
class AppTextStyles {
  AppTextStyles._();

  // === Headings ===
  static const TextStyle h1 = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // === Body ===
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  // === Labels ===
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.27,
  );

  // === Others ===
  static const TextStyle button = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
}

/// Visibility-aware text styles with MD3 theme colors pre-applied.
///
/// Use these when you want text to automatically adapt to light/dark themes
/// without manually specifying colors:
///
///   Text('Title', style: ThemedTextStyles.title(context))
///   Text('Body text', style: ThemedTextStyles.body(context))
///   Text('Caption', style: ThemedTextStyles.caption(context))
///
/// Color roles follow MD3 contrast hierarchy:
/// - `title` → onSurface (highest contrast, primary content)
/// - `body` → onSurface (primary content)
/// - `subtitle` → onSurfaceVariant (secondary content)
/// - `caption` → onSurfaceVariant (metadata, timestamps)
/// - `label` → onSurfaceVariant (form labels, chip text)
/// - `primary` → primary (accent content, active states)
/// - `inverse` → onInverseSurface (text on dark surfaces)
class ThemedTextStyles {
  ThemedTextStyles._();

  /// Primary title — highest visibility (onSurface).
  static TextStyle title(BuildContext context) =>
      AppTextStyles.h4.copyWith(color: _cs(context).onSurface);

  /// Secondary title — section headers.
  static TextStyle subtitle(BuildContext context) =>
      AppTextStyles.body.copyWith(color: _cs(context).onSurfaceVariant);

  /// Body text — primary content.
  static TextStyle body(BuildContext context) =>
      AppTextStyles.body.copyWith(color: _cs(context).onSurface);

  /// Body text — secondary/metadata.
  static TextStyle bodySecondary(BuildContext context) =>
      AppTextStyles.bodySmall.copyWith(color: _cs(context).onSurfaceVariant);

  /// Caption — timestamps, metadata.
  static TextStyle caption(BuildContext context) =>
      AppTextStyles.caption.copyWith(color: _cs(context).onSurfaceVariant);

  /// Label — form labels, chip text.
  static TextStyle label(BuildContext context) =>
      AppTextStyles.labelMedium.copyWith(color: _cs(context).onSurfaceVariant);

  /// Accent text — active states, key values.
  static TextStyle primary(BuildContext context) =>
      AppTextStyles.body.copyWith(color: _cs(context).primary);

  /// Inverse text — for dark surfaces (snackbars, inverted cards).
  static TextStyle inverse(BuildContext context) =>
      AppTextStyles.bodySmall.copyWith(color: _cs(context).onInverseSurface);

  /// Error text — validation errors, destructive states.
  static TextStyle error(BuildContext context) =>
      AppTextStyles.bodySmall.copyWith(color: _cs(context).error);

  /// Warning text — low stock, attention states.
  static TextStyle warning(BuildContext context) =>
      AppTextStyles.bodySmall.copyWith(color: AppColors.warning);

  /// Success text — confirmations, positive states.
  static TextStyle success(BuildContext context) =>
      AppTextStyles.bodySmall.copyWith(color: AppColors.success);

  static ColorScheme _cs(BuildContext context) =>
      Theme.of(context).colorScheme;
}

/// TextTheme integration helper.
///
/// Provides a way to get AppTextStyles-mapped TextTheme from BuildContext.
/// Use this when you want custom sizing (h1-h4, body, label) with automatic
/// theme-aware colors:
///
///   Text('Hello', style: context.appTextTheme.titleLarge)
///
/// Or use ThemeData.textTheme directly (already wired in AppTheme):
///
///   Text('Hello', style: Theme.of(ctx).textTheme.titleLarge)
extension AppTextStylesExtension on BuildContext {
  /// Returns AppTextStyles cast as a TextTheme (all roles pre-mapped).
  TextTheme get appTextTheme => Theme.of(this).textTheme;
}

/// Custom icons for nVentory
class AppIcons {
  AppIcons._();

  // Navigation
  static const IconData inventory = Icons.inventory_2_outlined;
  static const IconData inventoryFilled = Icons.inventory_2;
  static const IconData dashboard = Icons.dashboard_outlined;
  static const IconData dashboardFilled = Icons.dashboard;
  static const IconData people = Icons.people_outline;
  static const IconData peopleFilled = Icons.people;
  static const IconData analytics = Icons.analytics_outlined;
  static const IconData analyticsFilled = Icons.analytics;

  // Actions
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData scan = Icons.qr_code_scanner;
  static const IconData import = Icons.file_download_outlined;
  static const IconData export = Icons.file_upload_outlined;

  // Status
  static const IconData success = Icons.check_circle_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData error = Icons.error_outline;
  static const IconData info = Icons.info_outline;

  // Item
  static const IconData category = Icons.category_outlined;
  static const IconData location = Icons.location_on_outlined;
  static const IconData supplier = Icons.local_shipping_outlined;
  static const IconData barcode = Icons.qr_code;
  static const IconData image = Icons.image_outlined;
  static const IconData attachment = Icons.attach_file;

  // Misc
  static const IconData more = Icons.more_vert;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
  static const IconData expand = Icons.expand_more;
  static const IconData collapse = Icons.expand_less;
  static const IconData refresh = Icons.refresh;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData clock = Icons.access_time;
}

/// Icon theme helper for nVentory.
///
/// Provides pre-themed icon configurations that automatically adapt to
/// light/dark themes. Use these for consistent icon visibility:
///
///   Icon(AppIconThemes.navigation(context), icon: AppIcons.dashboard)
///   Icon(AppIconThemes.action(context), icon: AppIcons.add)
///   Icon(AppIconThemes.status(context, isWarning: true), icon: AppIcons.warning)
class AppIconThemes {
  AppIconThemes._();

  /// Navigation icons — subtle, non-primary.
  static IconData navigation(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppIcons.dashboard
          : AppIcons.dashboardFilled;

  /// Action icons — primary color for CTAs.
  static Color actionColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Status icon color — adapts based on state.
  static Color statusColor(BuildContext context, {
    bool isWarning = false,
    bool isError = false,
    bool isSuccess = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    if (isError) {
      return cs.error;
    }
    if (isWarning) {
      return AppColors.warning;
    }
    if (isSuccess) {
      return AppColors.success;
    }
    return cs.onSurfaceVariant;
  }

  /// Navigation icon color — for nav bars/rails.
  static Color navigationColor(BuildContext context, {bool isSelected = false}) {
    final cs = Theme.of(context).colorScheme;
    return isSelected ? cs.onSurface : cs.onSurfaceVariant;
  }

  /// Icon size presets per MD3 spec.
  static const double sizeXs = 12;
  static const double sizeSm = 16;
  static const double sizeMd = 20;
  static const double sizeLg = 24;
  static const double sizeXl = 32;
  static const double size2xl = 48;
}
