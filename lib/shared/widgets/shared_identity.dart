import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class NuriLogo extends StatelessWidget {
  const NuriLogo({
    super.key,
    this.compact = false,
    this.onDark = false,
    this.vertical = false,
    this.size,
    this.subtitle,
  });

  final bool compact;
  final bool onDark;
  final bool vertical;
  final double? size;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textColor = onDark ? Colors.white : AppColors.onSurface;
    final subColor = onDark
        ? Colors.white.withValues(alpha: 0.78)
        : AppColors.secondaryText;
    final dotColor = onDark ? AppColors.secondaryFixed : AppColors.primary;

    final emblemSize = size ?? (vertical ? 68.0 : (compact ? 32.0 : 38.0));

    final emblem = Container(
      width: emblemSize,
      height: emblemSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: onDark ? Colors.white.withValues(alpha: 0.25) : AppColors.line,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (onDark ? Colors.black : AppColors.primary).withValues(
              alpha: 0.12,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(emblemSize * 0.1),
      child: Image.asset(
        'assets/images/nuri_logo_mark.png',
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.spa_rounded,
          color: AppColors.primary,
          size: emblemSize * 0.55,
        ),
      ),
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          emblem,
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'NURI',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: compact ? 20 : 24,
                letterSpacing: -0.4,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: '.',
                  style: TextStyle(color: dotColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle ?? 'Nutrisi & Risiko Stunting di Indonesia',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: compact ? 10 : 11.5,
              fontWeight: FontWeight.w700,
              color: subColor,
              letterSpacing: 0.3,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 2),
            Text(
              'Tumbuh Sehat, Keluarga Kuat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: subColor.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                text: 'NURI',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 18 : 20,
                  letterSpacing: -0.3,
                  color: textColor,
                  height: 1,
                ),
                children: [
                  TextSpan(
                    text: '.',
                    style: TextStyle(color: dotColor),
                  ),
                ],
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 2),
              Text(
                subtitle ?? 'Kesehatan Ibu & Balita',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: subColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ],
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
