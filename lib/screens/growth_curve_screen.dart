import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/who_growth_reference.dart';
import '../services/child_service.dart';
import '../services/measurement_service.dart';

/// Kurva pertumbuhan TB/U-PB/U (F-09) + titik pengukuran anak.
/// Garis referensi -3/-2/median/+2/+3 SD dari anchor WHO demo.
class GrowthCurveScreen extends StatelessWidget {
  final String childId;
  const GrowthCurveScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final child = ChildService().findById(childId);
    final points = MeasurementService().forChild(childId);
    final isBoy = (child?.gender ?? 'L') == 'L';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kurva ${child?.name ?? ''}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Referensi WHO (L=1): garis -3/-2/median/+2/+3 SD, diperbarui tiap pengukuran baru.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: CustomPaint(
                  painter: _CurvePainter(isBoy: isBoy, points: points),
                  child: Container(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              points.isEmpty
                  ? 'Belum ada pengukuran. Lakukan skrining lalu Simpan.'
                  : '${points.length} pengukuran tersimpan.',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  final bool isBoy;
  final List<Measurement> points;
  _CurvePainter({required this.isBoy, required this.points});

  double _refAt(int month, double sd) {
    final lms = WhoGrowthReference.lmsFor(month: month, isBoy: isBoy);
    return lms.median * (1 + lms.s * sd);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const months = [0, 12, 24, 36, 48, 60];
    double minY = 45, maxY = 115;
    Offset toPx(int m, double h) {
      final x = (m / 60) * (size.width - 40) + 30;
      final y = size.height - 20 - ((h - minY) / (maxY - minY)) * (size.height - 40);
      return Offset(x, y);
    }

    final lines = {
      -3.0: Colors.red,
      -2.0: Colors.orange,
      0.0: Colors.green,
      2.0: Colors.blue.shade300,
      3.0: Colors.blue,
    };
    for (final entry in lines.entries) {
      final paint = Paint()
        ..color = entry.value.withValues(alpha: entry.key == 0 ? 0.9 : 0.5)
        ..strokeWidth = entry.key == 0 ? 2.5 : 1.5;
      final path = Path();
      for (var i = 0; i < months.length; i++) {
        final p = toPx(months[i], _refAt(months[i], entry.key));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    final dotPaint = Paint()..color = Colors.black87;
    for (final m in points) {
      final p = toPx(m.ageMonths.clamp(0, 60), m.correctedCm);
      canvas.drawCircle(p, 5, Paint()..color = Colors.teal);
      canvas.drawCircle(p, 5, dotPaint..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
