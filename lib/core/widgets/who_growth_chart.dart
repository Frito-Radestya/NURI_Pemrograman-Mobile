import 'package:flutter/material.dart';

import '../../domain/models/sex.dart';
import '../../domain/models/who_lms.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Satu titik pengukuran pada kurva (umur bulan, tinggi cm).
class WhoChartPoint {
  const WhoChartPoint({required this.month, required this.cm, this.isLatest = false});

  final int month;
  final double cm;
  final bool isLatest;
}

/// Kurva pertumbuhan WHO: garis \u22123, \u22122, median, +2, +3 SD beserta titik anak (F6).
class WhoGrowthChart extends StatelessWidget {
  const WhoGrowthChart({
    super.key,
    required this.table,
    required this.sex,
    required this.points,
    this.height = 210,
    this.maxMonth = 60,
  });

  final WhoLmsTable table;
  final Sex sex;
  final List<WhoChartPoint> points;
  final double height;
  final int maxMonth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WhoPainter(table: table, sex: sex, points: points, maxMonth: maxMonth),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WhoPainter extends CustomPainter {
  _WhoPainter({
    required this.table,
    required this.sex,
    required this.points,
    required this.maxMonth,
  });

  final WhoLmsTable table;
  final Sex sex;
  final List<WhoChartPoint> points;
  final int maxMonth;

  static const List<double> _lines = [-3, -2, 0, 2, 3];

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 30;
    const double rightPad = 10;
    const double topPad = 12;
    const double bottomPad = 26;
    final double w = size.width - leftPad - rightPad;
    final double h = size.height - topPad - bottomPad;

    // Rentang nilai dari -3 SD di umur 0 s/d +3 SD di umur max.
    final double yMin = table.at(sex, 0).valueForZ(-3);
    final double yMax = table.at(sex, maxMonth).valueForZ(3);
    double xFor(int month) => leftPad + (month / maxMonth) * w;
    double yFor(double cm) => topPad + h - ((cm - yMin) / (yMax - yMin)) * h;

    // Pita hijau -2..+2 SD.
    final Path band = Path();
    for (int m = 0; m <= maxMonth; m++) {
      final double x = xFor(m);
      final double y = yFor(table.valueForZ(sex, m, 2));
      m == 0 ? band.moveTo(x, y) : band.lineTo(x, y);
    }
    for (int m = maxMonth; m >= 0; m--) {
      band.lineTo(xFor(m), yFor(table.valueForZ(sex, m, -2)));
    }
    band.close();
    canvas.drawPath(band, Paint()..color = AppColors.pastelGreenSoft.withValues(alpha: 0.9));

    // Grid horizontal tipis.
    final Paint grid = Paint()
      ..color = AppColors.lineSoft
      ..strokeWidth = 1;
    for (final double z in _lines) {
      final double y = yFor(table.valueForZ(sex, maxMonth, z));
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + w, y), grid);
    }

    // Garis SD.
    for (final double z in _lines) {
      final Path path = Path();
      for (int m = 0; m <= maxMonth; m++) {
        final double x = xFor(m);
        final double y = yFor(table.valueForZ(sex, m, z));
        m == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      final bool median = z == 0;
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = median ? 1.8 : 1.2
          ..color = median ? AppColors.brand : AppColors.lineStrong,
      );
    }

    // Garis & titik anak.
    final List<WhoChartPoint> sorted = List<WhoChartPoint>.of(points)
      ..sort((WhoChartPoint a, WhoChartPoint b) => a.month.compareTo(b.month));
    if (sorted.isNotEmpty) {
      final Path child = Path();
      for (int i = 0; i < sorted.length; i++) {
        final double x = xFor(sorted[i].month);
        final double y = yFor(sorted[i].cm);
        i == 0 ? child.moveTo(x, y) : child.lineTo(x, y);
      }
      if (sorted.length > 1) {
        canvas.drawPath(
          child,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round
            ..color = AppColors.ink,
        );
      }
      for (final WhoChartPoint p in sorted) {
        final Offset c = Offset(xFor(p.month), yFor(p.cm));
        canvas.drawCircle(
          c,
          p.isLatest ? 5.5 : 3.5,
          Paint()..color = p.isLatest ? AppColors.ink : AppColors.surface,
        );
        canvas.drawCircle(
          c,
          p.isLatest ? 5.5 : 3.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = AppColors.brand,
        );
      }
    }

    // Label SD di kiri.
    for (final double z in _lines) {
      final double y = yFor(table.valueForZ(sex, maxMonth, z));
      final String label = z > 0 ? '+${z.toInt()}' : z.toInt().toString();
      _text(
        canvas,
        label,
        Offset(0, y - 6),
        AppText.caption.copyWith(fontSize: 9, color: AppColors.inkFaint),
      );
    }

    // Label umur di bawah.
    for (final int m in <int>[0, 12, 24, 36, 48, 60]) {
      if (m > maxMonth) continue;
      _text(
        canvas,
        '$m',
        Offset(xFor(m) - 6, size.height - 14),
        AppText.caption.copyWith(fontSize: 9, color: AppColors.inkFaint),
      );
    }
  }

  void _text(Canvas canvas, String value, Offset at, TextStyle style) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant _WhoPainter old) =>
      old.points != points || old.sex != sex || old.maxMonth != maxMonth;
}
