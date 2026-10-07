import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Foto dengan sudut membulat, efek memuat halus, dan cadangan gradien
/// bila gambar tidak dapat dimuat (mode offline).
class NuriPhoto extends StatelessWidget {
  const NuriPhoto({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.radius = 24,
    this.fit = BoxFit.cover,
    this.overlay,
    this.fallbackIcon = Icons.restaurant_rounded,
  });

  final String url;
  final double? height;
  final double? width;
  final double radius;
  final BoxFit fit;
  final Widget? overlay;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const _PhotoFallback(icon: Icons.image_rounded);
              },
              errorBuilder: (context, error, stack) =>
                  _PhotoFallback(icon: fallbackIcon),
            ),
            ?overlay,
          ],
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDE7DA), Color(0xFFC9D9C6)],
        ),
      ),
      child: Center(
        child: Icon(icon, color: AppColors.surface.withValues(alpha: 0.8), size: 42),
      ),
    );
  }
}
