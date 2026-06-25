import 'package:flutter/material.dart';

/// Micro-animation durations and curves for nVentory.
class AppAnimations {
  AppAnimations._();

  // === Durations ===
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);

  // === Curves ===
  static const Curve standard = Curves.easeInOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve decelerate = Curves.easeOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve sharp = Curves.easeInOutCubic;

  // === Page transitions ===
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;

  // === Stagger delays for list animations ===
  static const Duration staggerDelay = Duration(milliseconds: 50);
}

/// Pre-built animated widgets for common patterns.
class AnimatedBuilders {
  AnimatedBuilders._();

  /// Fade in + slide up animation for list items
  static Widget fadeSlideIn({
    required Widget child,
    required Animation<double> animation,
    double slideOffset = 20,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.decelerate,
    );
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, slideOffset / 100),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  /// Scale in animation for cards and dialogs
  static Widget scaleIn({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: AppAnimations.standard,
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Shimmer loading placeholder
  static Widget shimmer({
    required BuildContext context,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            cs.surfaceContainerHighest,
            cs.surfaceContainerHighest.withValues(alpha: 0.5),
            cs.surfaceContainerHighest,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
