import 'package:flutter/material.dart';

/// Typography system for nVentory using Open Sans.
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
  static const IconData settings = Icons.settings_outlined;
  static const IconData settingsFilled = Icons.settings;
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
