import 'package:flutter/material.dart';

import 'landing_models.dart';

class Slide2WhoChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 320;
    final sy = size.height / 250;
    canvas.save();
    canvas.scale(sx, sy);

    // Background soft circle
    canvas.drawCircle(
      const Offset(165, 125),
      95,
      Paint()..color = LandingColors.forestGreen.withValues(alpha: 0.07),
    );

    // Chart card
    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(74, 28, 216, 176),
      const Radius.circular(18),
    );
    canvas.drawRRect(cardRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = LandingColors.forestGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2ECE0)
      ..strokeWidth = 1.2;
    for (final y in [82.0, 114.0, 146.0, 178.0]) {
      canvas.drawLine(Offset(92, y), Offset(274, y), gridPaint);
    }

    // Green shaded WHO band
    final bandPath = Path()
      ..moveTo(92, 160)
      ..quadraticBezierTo(175, 125, 272, 70)
      ..lineTo(272, 110)
      ..quadraticBezierTo(175, 155, 92, 182)
      ..close();
    canvas.drawPath(
      bandPath,
      Paint()..color = LandingColors.leafGreen.withValues(alpha: 0.2),
    );

    // Main curve
    final curvePath = Path()
      ..moveTo(92, 170)
      ..quadraticBezierTo(175, 132, 266, 84);
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = LandingColors.forestGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Data points
    final dotPaint = Paint()..color = LandingColors.forestGreen;
    canvas.drawCircle(const Offset(92, 170), 4, dotPaint);
    canvas.drawCircle(const Offset(148, 142), 4.5, dotPaint);
    canvas.drawCircle(const Offset(206, 113), 4.5, dotPaint);
    canvas.drawCircle(
      const Offset(266, 84),
      6,
      Paint()..color = LandingColors.leafGreen,
    );

    // Left vertical stadiometer ruler
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 22, 34, 190),
        const Radius.circular(10),
      ),
      Paint()..color = LandingColors.deepGreen,
    );
    // Ruler ticks
    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.5;
    for (double y = 40; y < 195; y += 16) {
      canvas.drawLine(Offset(48, y), Offset(62, y), tickPaint);
    }

    // Green measurement indicator pill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 56, 98, 26),
        const Radius.circular(8),
      ),
      Paint()..color = LandingColors.leafGreen,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter for Slide 3: Exact replica of onboarding_slide_03_penuhi_nutrisi.svg
class Slide3PlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 320;
    final sy = size.height / 250;
    canvas.save();
    canvas.scale(sx, sy);

    const center = Offset(160, 120);

    // Outer soft halo
    canvas.drawCircle(
      center,
      96,
      Paint()..color = LandingColors.leafGreen.withValues(alpha: 0.10),
    );

    // Plate rim
    canvas.drawCircle(center, 76, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      76,
      Paint()
        ..color = LandingColors.forestGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Inner plate well
    canvas.drawCircle(center, 60, Paint()..color = LandingColors.naturalWhite);
    canvas.drawCircle(
      center,
      60,
      Paint()
        ..color = LandingColors.leafGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Quadrant dividers
    final divPaint = Paint()
      ..color = LandingColors.forestGreen.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(160, 60), const Offset(160, 180), divPaint);
    canvas.drawLine(const Offset(100, 120), const Offset(220, 120), divPaint);

    // Top-left: Vegetables (broccoli/greens)
    canvas.drawCircle(
      const Offset(128, 90),
      12,
      Paint()..color = LandingColors.forestGreen,
    );
    canvas.drawCircle(
      const Offset(140, 86),
      10,
      Paint()..color = LandingColors.leafGreen,
    );
    canvas.drawCircle(
      const Offset(134, 98),
      9,
      Paint()..color = LandingColors.leafGreen,
    );

    // Top-right: Fruit
    canvas.drawCircle(
      const Offset(188, 94),
      14,
      Paint()..color = LandingColors.leafGreen,
    );

    // Bottom-left: Protein
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(132, 148), width: 30, height: 22),
      Paint()..color = LandingColors.forestGreen,
    );
    canvas.drawCircle(
      const Offset(130, 148),
      6,
      Paint()..color = LandingColors.leafGreen,
    );

    // Bottom-right: Carbs / Rice bowl
    final bowlPath = Path()
      ..moveTo(172, 150)
      ..lineTo(204, 150)
      ..quadraticBezierTo(188, 164, 172, 150)
      ..close();
    canvas.drawPath(bowlPath, Paint()..color = LandingColors.leafGreen);
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(188, 150), width: 28, height: 20),
      3.14,
      3.14,
      true,
      Paint()..color = LandingColors.deepGreen,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
