import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.loading,
    required this.onPressed,
    this.label = 'Masuk dengan Google',
  });

  final bool loading;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GoogleLogoIcon(),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
    );
  }
}

class _GoogleLogoIcon extends StatelessWidget {
  const _GoogleLogoIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(18, 18), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w / 2;

    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    // 4 quadrants arcs
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.785,
      1.57,
      true,
      blue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.785,
      1.57,
      true,
      green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.355,
      1.57,
      true,
      yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.925,
      1.57,
      true,
      red,
    );

    // Inner cutout
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.58, white);

    // Center bar
    final barRect = Rect.fromLTRB(
      cx - r * 0.1,
      cy - r * 0.22,
      w * 0.95,
      cy + r * 0.22,
    );
    canvas.drawRect(barRect, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
