import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CurvedHeader extends StatelessWidget {
  const CurvedHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.gradient = AppGradients.headerWide,
    this.borderRadius = 32,
    this.showAmbientBlobs = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final double borderRadius;
  final bool showAmbientBlobs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(borderRadius),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240D631B),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            if (showAmbientBlobs) ...[
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryFixed.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ],
            Padding(
              padding: padding,
              child: SizedBox(width: double.infinity, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class NuriPageHeader extends StatelessWidget {
  const NuriPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 23, letterSpacing: -0.4),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 18),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.onBack,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(20, 10, 20, 14),
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final VoidCallback? onBack;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null) ...[
            _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: onBack!),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontSize: 21, letterSpacing: -0.35),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 10), action!],
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 20, color: AppColors.text),
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surface,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppColors.line),
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? Colors.white : AppColors.text,
        ),
      ),
    );
  }
}

class NuriSectionLabel extends StatelessWidget {
  const NuriSectionLabel({
    super.key,
    required this.text,
    this.color = AppColors.muted,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
