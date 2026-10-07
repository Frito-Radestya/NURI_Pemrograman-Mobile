import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Kurva pertumbuhan bergaya "pita hijau sehat" (WHO).
class GrowthChart extends StatelessWidget {
  const GrowthChart({
    super.key,
    required this.points,
    this.labels = const [],
    this.height = 190,
    this.highlightIndex,
    this.highlightLabel,
    this.showBand = true,
  });

  final List<double> points; // nilai 0..1 ternormalisasi
  final List<String> labels;
  final double height;
  final int? highlightIndex;
  final String? highlightLabel;
  final bool showBand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _GrowthPainter(
          points: points,
          highlightIndex: highlightIndex,
          showBand: showBand,
        ),
        child: Stack(
          children: [
            if (labels.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels
                      .map((l) => Text(l, style: AppText.caption.copyWith(fontSize: 10)))
                      .toList(),
                ),
              ),
            if (highlightIndex != null && highlightLabel != null)
              Positioned(
                left: 0,
                right: 0,
                top: 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7BE0A5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          highlightLabel!,
                          style: AppText.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GrowthPainter extends CustomPainter {
  _GrowthPainter({
    required this.points,
    this.highlightIndex,
    this.showBand = true,
  });

  final List<double> points;
  final int? highlightIndex;
  final bool showBand;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    const bottomPad = 22.0;
    const topPad = 16.0;
    final h = size.height - bottomPad - topPad;
    final w = size.width;
    final dx = w / (points.length - 1);

    double yFor(double v) => topPad + h - (v.clamp(0, 1) * h);

    // Pita hijau.
    if (showBand) {
      final upper = <Offset>[];
      final lower = <Offset>[];
      for (var i = 0; i < points.length; i++) {
        final x = dx * i;
        final v = points[i];
        upper.add(Offset(x, yFor((v + 0.12).clamp(0, 1))));
        lower.add(Offset(x, yFor((v - 0.12).clamp(0, 1))));
      }
      final path = Path()..moveTo(upper.first.dx, upper.first.dy);
      for (final p in upper.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      for (final p in lower.reversed) {
        path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()..color = AppColors.pastelGreenSoft.withValues(alpha: 0.9),
      );

      final medianPath = Path()
        ..moveTo(upper.first.dx, yFor(points.first));
      for (var i = 1; i < points.length; i++) {
        medianPath.lineTo(dx * i, yFor(points[i]));
      }
      canvas.drawPath(
        medianPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = AppColors.lineStrong,
      );
    }

    // Garis tren anak.
    final line = Path()..moveTo(0, yFor(points.first));
    for (var i = 1; i < points.length; i++) {
      line.lineTo(dx * i, yFor(points[i]));
    }
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = AppColors.brand,
    );

    // Titik.
    for (var i = 0; i < points.length; i++) {
      final center = Offset(dx * i, yFor(points[i]));
      final isHi = highlightIndex == i;
      canvas.drawCircle(
        center,
        isHi ? 6 : 4,
        Paint()..color = isHi ? AppColors.ink : AppColors.surface,
      );
      canvas.drawCircle(
        center,
        isHi ? 6 : 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.brand,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthPainter old) =>
      old.points != points || old.highlightIndex != highlightIndex;
}
