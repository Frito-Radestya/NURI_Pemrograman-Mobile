import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Ring kemajuan melingkar dengan label persen di tengah.
class NutrientRing extends StatelessWidget {
  const NutrientRing({
    super.key,
    required this.value,
    this.size = 84,
    this.stroke = 9,
    this.color = AppColors.brand,
    this.backgroundColor = AppColors.lineSoft,
    this.trackLabel,
    this.center,
  });

  final double value; // 0..1
  final double size;
  final double stroke;
  final Color color;
  final Color backgroundColor;
  final String? trackLabel;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              value: value.clamp(0, 1),
              stroke: stroke,
              color: color,
              background: backgroundColor,
            ),
          ),
          if (center != null)
            center!
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).round()}%',
                  style: AppText.h3.copyWith(fontSize: size * 0.24),
                ),
                if (trackLabel != null)
                  Text(trackLabel!, style: AppText.caption.copyWith(fontSize: 10)),
              ],
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.background,
  });

  final double value;
  final double stroke;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = background;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}

/// Bilah kemajuan horizontal bergaya pil.
class NutrientBar extends StatelessWidget {
  const NutrientBar({
    super.key,
    required this.value,
    this.color = AppColors.brand,
    this.background = AppColors.lineSoft,
    this.height = 8,
  });

  final double value; // 0..1
  final Color color;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: height, color: background),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(height: height, color: color),
          ),
        ],
      ),
    );
  }
}

/// Kartu metrik nutrisi (angka besar + label + satuan).
class NutrientMetric extends StatelessWidget {
  const NutrientMetric({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.color = AppColors.ink,
  });

  final String value;
  final String unit;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppText.metric.copyWith(color: color),
              ),
              TextSpan(
                text: ' $unit',
                style: AppText.bodySm.copyWith(color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppText.caption),
      ],
    );
  }
}
