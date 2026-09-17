import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Wave clipper matching the curved teal header in the mockups.
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 28,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 56,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class WaveHeader extends StatelessWidget {
  final double height;
  final Widget? child;

  const WaveHeader({super.key, this.height = 220, this.child});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -40,
              child: _blob(140, 0.12),
            ),
            Positioned(
              top: 60,
              left: -20,
              child: _blob(90, 0.1),
            ),
            Positioned(
              bottom: 40,
              right: 40,
              child: _blob(50, 0.15),
            ),
            ?child,
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
