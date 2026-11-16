import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.background = AppColors.mint,
    this.foreground = AppColors.primaryDark,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.fontSize = 11.5,
    this.bold = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.2,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GrowthStatusBadge extends StatelessWidget {
  const GrowthStatusBadge({
    super.key,
    required this.category,
    this.compact = false,
  });

  final GrowthCategory category;
  final bool compact;

  static (Color, Color, IconData) colorsFor(GrowthCategory category) =>
      switch (category) {
        GrowthCategory.normal => (
          AppColors.mint,
          AppColors.primaryDark,
          Icons.check_circle_outline_rounded,
        ),
        GrowthCategory.stunted => (
          AppColors.amberSoft,
          AppColors.amber,
          Icons.trending_down_rounded,
        ),
        GrowthCategory.severelyStunted => (
          AppColors.redSoft,
          AppColors.red,
          Icons.error_outline_rounded,
        ),
        GrowthCategory.tall => (
          AppColors.blueSoft,
          AppColors.blue,
          Icons.trending_up_rounded,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final colors = colorsFor(category);
    return Pill(
      label: category.label,
      icon: colors.$3,
      background: colors.$1,
      foreground: colors.$2,
      fontSize: compact ? 11 : 11.5,
      bold: true,
    );
  }
}

class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, required this.pending});

  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: pending ? 'Tertunda' : 'Tersinkron',
      icon: pending ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
      background: pending ? AppColors.amberSoft : AppColors.mint,
      foreground: pending ? AppColors.amber : AppColors.primary,
      fontSize: 11,
    );
  }
}
