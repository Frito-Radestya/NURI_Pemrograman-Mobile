import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../ui.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surfaceContainerLowest,
    this.borderColor = AppColors.line,
    this.radius = AppRadius.card,
    this.onTap,
    this.shadow = true,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;
  final bool shadow;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: shadow ? AppShadows.card : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    if (onTap == null) return card;
    return NuriTapScale(child: card);
  }
}

class LinearProgress extends StatelessWidget {
  const LinearProgress({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.background = AppColors.surfaceSubtle,
    this.height = 7,
  });

  final double value;
  final Color color;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    final safe = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: safe),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Stack(
          children: [
            Container(height: height, color: background),
            FractionallySizedBox(
              widthFactor: animation,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.title,
    this.body,
    this.icon = Icons.info_outline_rounded,
    this.background = AppColors.surfaceSubtle,
    this.foreground = AppColors.text,
    this.trailing,
  });

  final String title;
  final String? body;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: foreground),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                    height: 1.3,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    body!,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: foreground == AppColors.text
                          ? AppColors.muted
                          : foreground.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class MetricBox extends StatelessWidget {
  const MetricBox({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.note,
    this.noteColor = AppColors.primary,
    this.icon,
    this.background = AppColors.surfaceSubtle,
    this.valueSize = 20,
  });

  final String label;
  final String value;
  final String? unit;
  final String? note;
  final Color noteColor;
  final IconData? icon;
  final Color background;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, size: 14, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: valueSize,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: AppColors.text,
                    height: 1.1,
                  ),
                ),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 12,
                  color: noteColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: noteColor,
                      fontWeight: FontWeight.w600,
                    ),
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

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.body,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showNuriSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.red : AppColors.primaryDeep,
        duration: const Duration(seconds: 3),
      ),
    );
}
