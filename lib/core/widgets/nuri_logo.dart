import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Ikon brand NURI: bulir/daun hijau di dalam bidang membulat.
class NuriMark extends StatelessWidget {
  const NuriMark({super.key, this.size = 44, this.color = AppColors.brandText});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.25)!],
        ),
      ),
      child: CustomPaint(
        painter: _NuriMarkPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NuriMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Bulir besar (kiri).
    final left = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.24, w * 0.2, h * 0.52),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(left, paint);

    // Bulir kanan sedikit lebih pendek.
    final right = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.5, h * 0.32, w * 0.18, h * 0.36),
      Radius.circular(w * 0.09),
    );
    canvas.drawRRect(right, paint);

    // Titik (biji) aksen.
    canvas.drawCircle(
      Offset(w * 0.57, h * 0.44),
      w * 0.045,
      Paint()..color = const Color(0xFFFFC24B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wordmark "nuri" (lowercase, hijau).
class NuriWordmark extends StatelessWidget {
  const NuriWordmark({
    super.key,
    this.fontSize = 26,
    this.color = AppColors.brandText,
  });

  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'nuri',
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: fontSize,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        color: color,
      ),
    );
  }
}

/// Lockup logo + wordmark untuk app bar.
class NuriBrand extends StatelessWidget {
  const NuriBrand({super.key, this.markSize = 30, this.fontSize = 20});

  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NuriMark(size: markSize),
        const SizedBox(width: 8),
        NuriWordmark(fontSize: fontSize, color: AppColors.ink),
      ],
    );
  }
}

/// Label kecil bergaya "STANDAR ANTROPOMETRI ..." pada splash.
class NuriEyebrowChip extends StatelessWidget {
  const NuriEyebrowChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.label.copyWith(
                color: AppColors.ink,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
