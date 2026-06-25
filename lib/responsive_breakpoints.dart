import 'package:flutter/material.dart';

/// Responsive breakpoints for adaptive layouts.
/// 
/// Mobile: < 600px
/// Tablet: 600px - 1024px
/// Desktop: > 1024px
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Content max width for large screens
  static const double contentMaxWidth = 1200;

  /// Navigation rail width
  static const double navRailWidth = 256;

  /// Standard padding values
  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 16;
  static const double paddingLg = 24;
  static const double paddingXl = 32;
  static const double padding2xl = 48;

  /// Border radius values
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 28;
}

/// Extension to easily check screen size from BuildContext.
extension ResponsiveExtension on BuildContext {
  /// Returns the current screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the current screen height.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// True if the screen is mobile size (< 600px).
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// True if the screen is tablet size (600px - 1024px).
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// True if the screen is desktop size (>= 1024px).
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Returns the appropriate padding based on screen size.
  double get responsivePadding {
    if (isMobile) {
      return Breakpoints.paddingMd;
    }
    if (isTablet) {
      return Breakpoints.paddingLg;
    }
    return Breakpoints.paddingXl;
  }

  /// Returns the number of columns for a grid based on screen size.
  int get gridColumns {
    if (isMobile) {
      return 1;
    }
    if (isTablet) {
      return 2;
    }
    return 3;
  }

  /// Returns a constrained width for content on large screens.
  double get constrainedWidth {
    if (isDesktop) {
      return Breakpoints.contentMaxWidth;
    }
    return screenWidth;
  }
}

/// A widget that builds different layouts based on screen size.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!(context);
    }
    if (context.isTablet && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

/// A widget that constrains content to a max width on large screens.
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contentMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.all(context.responsivePadding),
          child: child,
        ),
      ),
    );
  }
}
