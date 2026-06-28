import 'package:flutter/material.dart';
import '../design/typography.dart';
import '../responsive_breakpoints.dart';

/// Reusable hero area widget for consistent screen headers.
///
/// Provides a standardized top section with:
/// - Optional nV logo
/// - Title (h4 or h3 on desktop)
/// - Subtitle / context line
/// - Dynamic stat chips (counts, dates, status)
///
/// Usage:
/// ```dart
/// HeroSection(
///   title: 'Inventory',
///   subtitle: 'Manage your stock items',
///   showLogo: true,
///   showDate: true,
///   stats: [
///     HeroStat(label: 'Total', value: '24', color: cs.primary),
///     HeroStat(label: 'Low Stock', value: '3', color: Colors.orange),
///   ],
/// )
/// ```
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
    this.showDate = false,
    this.stats,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final bool showLogo;
  final bool showDate;
  final List<HeroStat>? stats;
  final EdgeInsetsGeometry? padding;

  String _formatTodayDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: context.responsivePadding,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Logo + Title + Date
          Row(
            children: [
              if (showLogo) ...[
                Container(
                  width: isDesktop ? 36 : 32,
                  height: isDesktop ? 36 : 32,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'nV',
                      style: (isDesktop ? AppTextStyles.labelLarge : AppTextStyles.labelMedium).copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: (isDesktop ? AppTextStyles.h3 : AppTextStyles.h4).copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showDate) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTodayDate(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // Stats row
          if (stats != null && stats!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats!.map((stat) => _buildStatChip(cs, stat)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(ColorScheme cs, HeroStat stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            style: AppTextStyles.labelMedium.copyWith(
              color: stat.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            stat.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for a hero stat chip.
class HeroStat {
  const HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}
