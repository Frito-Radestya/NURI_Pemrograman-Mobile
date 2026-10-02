import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget progress ring nutrisi tunggal dengan label, nilai, dan warna
class NutritionRingWidget extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Color color;
  final String label;
  final String value;
  final String target;
  final double size;

  const NutritionRingWidget({
    super.key,
    required this.progress,
    required this.color,
    required this.label,
    required this.value,
    required this.target,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
              strokeWidth: 7,
            ),
            child: Center(
              child: Text(
                '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color;
}

/// Widget summary ring semua nutrisi dalam satu baris
class DailyNutritionRings extends StatelessWidget {
  final double caloriesProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const DailyNutritionRings({
    super.key,
    required this.caloriesProgress,
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NutritionRingWidget(
          progress: caloriesProgress,
          color: const Color(0xFFFF6B6B),
          label: 'Kalori',
          value: '${totalCalories.toStringAsFixed(0)} kkal',
          target: '2000 kkal',
        ),
        NutritionRingWidget(
          progress: proteinProgress,
          color: const Color(0xFF00C9A7),
          label: 'Protein',
          value: '${totalProtein.toStringAsFixed(1)} g',
          target: '56 g',
        ),
        NutritionRingWidget(
          progress: carbsProgress,
          color: const Color(0xFFFFB347),
          label: 'Karbo',
          value: '${totalCarbs.toStringAsFixed(1)} g',
          target: '260 g',
        ),
        NutritionRingWidget(
          progress: fatProgress,
          color: const Color(0xFF9B59B6),
          label: 'Lemak',
          value: '${totalFat.toStringAsFixed(1)} g',
          target: '65 g',
        ),
      ],
    );
  }
}

/// Traffic light badge: kurang / cukup / lebih
class TrafficLightBadge extends StatelessWidget {
  final String status; // 'kurang' | 'cukup' | 'lebih'

  const TrafficLightBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'cukup':
        color = const Color(0xFF00C9A7);
        label = 'Cukup';
        icon = Icons.check_circle_outline;
        break;
      case 'lebih':
        color = const Color(0xFFFF6B6B);
        label = 'Lebih';
        icon = Icons.arrow_upward_rounded;
        break;
      default:
        color = const Color(0xFFFFB347);
        label = 'Kurang';
        icon = Icons.arrow_downward_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
