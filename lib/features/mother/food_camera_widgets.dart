import 'package:flutter/material.dart';

class CameraIconButton extends StatelessWidget {
  const CameraIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  ViewfinderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 28.0;
    const radius = 12.0;
    final path = Path()
      ..moveTo(0, length + radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(length + radius, 0)
      ..moveTo(size.width - length - radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, length + radius)
      ..moveTo(size.width, size.height - length - radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(size.width - length - radius, size.height)
      ..moveTo(length + radius, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, size.height - length - radius);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ViewfinderPainter oldDelegate) =>
      oldDelegate.color != color;
}
