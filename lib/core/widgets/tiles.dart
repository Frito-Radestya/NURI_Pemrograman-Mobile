import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text.dart';

/// Ikon dalam kotak pastel membulat.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.pastelGreen,
    this.iconColor = AppColors.brand,
    this.size = 48,
    this.radius = 16,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.46),
    );
  }
}

/// Chip label yang menempel di atas foto.
class PhotoTag extends StatelessWidget {
  const PhotoTag({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.surface,
    this.color = AppColors.ink,
    this.trailing,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: AppText.bodySm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Kotak metrik kecil untuk grid (Berat, Tinggi, dst).
class MetricBox extends StatelessWidget {
  const MetricBox({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.trendColor = AppColors.brand,
    this.icon,
  });

  final String label;
  final String value;
  final String? unit;
  final String? trend;
  final Color trendColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppText.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, size: 16, color: AppColors.inkFaint),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: AppText.h2),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: AppText.bodySm.copyWith(color: AppColors.inkSoft),
                  ),
              ],
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 14, color: trendColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trend!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(color: trendColor),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Baris aksi/tujuan: ikon pastel, judul, subjudul, panah.
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.chevron_right_rounded,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.background = AppColors.surface,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 13),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.title.copyWith(fontSize: 14.5)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppText.bodySm.copyWith(fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showChevron)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.inkSoft),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu pilihan (mis. peran ibu/kader, jenis kelamin).
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.selected = false,
    this.onTap,
    this.badge,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final String? badge;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.canvasGreen : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.line,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    IconBadge(
                      icon: icon!,
                      color: selected
                          ? AppColors.brand
                          : AppColors.pastelGreenSoft,
                      iconColor:
                          selected ? Colors.white : AppColors.brand,
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge!,
                              style: AppText.caption.copyWith(
                                color: AppColors.inkSoft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(title, style: AppText.h3),
                      ],
                    ),
                  ),
                  _Selector(selected: selected),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(subtitle!, style: AppText.body.copyWith(fontSize: 13.5)),
              ],
              if (footer != null) ...[
                const SizedBox(height: 14),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Selector extends StatelessWidget {
  const _Selector({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: selected ? AppColors.brand : AppColors.surfaceSoft,
        shape: BoxShape.circle,
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}

/// Pilihan bergaya kotak (mis. Laki-laki / Perempuan).
class SegmentedChoice extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.label,
    this.caption,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? caption;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.brand : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: selected ? Colors.white : AppColors.brand,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: AppText.title.copyWith(
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    style: AppText.caption.copyWith(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.inkFaint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
