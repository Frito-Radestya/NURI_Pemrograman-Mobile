import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../domain/models.dart';
import 'ui.dart';

class NuriLogo extends StatelessWidget {
  const NuriLogo({super.key, this.compact = false, this.onDark = false});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? Colors.white : AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 38,
          height: compact ? 34 : 38,
          decoration: BoxDecoration(
            color: onDark
                ? Colors.white.withValues(alpha: 0.16)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(compact ? 11 : 12),
          ),
          child: Icon(
            Icons.spa_rounded,
            color: Colors.white,
            size: compact ? 19 : 21,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NURI',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: compact ? 19 : 21,
                letterSpacing: 0.4,
                color: color,
                height: 1,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 2),
              Text(
                'Sahabat Ibu & Balita',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: onDark
                      ? Colors.white.withValues(alpha: 0.72)
                      : AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.radius = AppRadius.card,
    this.onTap,
    this.shadow = false,
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
        boxShadow: shadow ? AppShadows.soft : null,
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

const _avatarColors = [
  (Color(0xFFFEE8DC), Color(0xFF9C4F2C)),
  (Color(0xFFE0F1EA), Color(0xFF0E6455)),
  (Color(0xFFFBE6EA), Color(0xFF963D52)),
  (Color(0xFFE8EEF8), Color(0xFF3D568E)),
  (Color(0xFFF4EBDC), Color(0xFF835E24)),
  (Color(0xFFECE7F7), Color(0xFF5A488E)),
  (Color(0xFFE2F0F5), Color(0xFF2B6278)),
  (Color(0xFFFCEFD7), Color(0xFF865A12)),
];

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.index = 0,
    this.imageAsset,
    this.showBadge = false,
  });

  final String name;
  final double size;
  final int index;
  final String? imageAsset;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final colors = _avatarColors[index % _avatarColors.length];
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.$1,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        image: imageAsset != null
            ? DecorationImage(image: AssetImage(imageAsset!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageAsset != null
          ? null
          : Text(
              initialsOf(name),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: size * 0.34,
                color: colors.$2,
              ),
            ),
    );
    if (!showBadge) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: size * 0.2,
            ),
          ),
        ),
      ],
    );
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

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.isCenter = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isCenter;
}

class NuriBottomNav extends StatelessWidget {
  const NuriBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  },
                  splashColor: AppColors.primary.withValues(alpha: 0.08),
                  highlightColor: Colors.transparent,
                  child: item.isCenter
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.activeIcon ?? item.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: Duration(
                                milliseconds: reduce ? 0 : 200,
                              ),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primarySoft
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                selected
                                    ? (item.activeIcon ?? item.icon)
                                    : item.icon,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.muted,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? AppColors.primaryDark
                                    : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
          ),
        ),
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
