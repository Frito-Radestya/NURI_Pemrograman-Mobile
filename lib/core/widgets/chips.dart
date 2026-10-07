import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Label kecil huruf kapital, mis. "LANGKAH 01" atau "LANGKAH 1 DARI 2".
class PillLabel extends StatelessWidget {
  const PillLabel({
    super.key,
    required this.text,
    this.leadingDot = true,
    this.color = AppColors.pastelGreenSoft,
    this.textColor = AppColors.brandText,
  });

  final String text;
  final bool leadingDot;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingDot) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text.toUpperCase(),
              style: AppText.label.copyWith(color: textColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip ikon + teks (mis. "Standar WHO", "Cegah Stunting").
class SoftChip extends StatelessWidget {
  const SoftChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.surfaceSoft,
    this.iconColor,
    this.textColor = AppColors.ink,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: iconColor ?? AppColors.brand),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppText.bodyStrong.copyWith(
                color: textColor,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip status kecil berwarna sesuai kategori.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.text,
    required this.color,
    this.onColor,
  });

  final String text;
  final Color color;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppText.label.copyWith(
          color: onColor ?? AppColors.ink,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Label kecil berdiri sendiri dengan latar pastel (mis. "Opsional").
class Tag extends StatelessWidget {
  const Tag({super.key, required this.text, this.color = AppColors.pastelGreen});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppText.caption.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge bertitik seperti "● Pediatrik & Gizi".
class DotBadge extends StatelessWidget {
  const DotBadge({
    super.key,
    required this.text,
    this.background = AppColors.pastelGreen,
    this.dotColor = AppColors.brand,
    this.textColor = AppColors.ink,
  });

  final String text;
  final Color background;
  final Color dotColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 7,
        runSpacing: 4,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          Text(
            text,
            style: AppText.bodySm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
