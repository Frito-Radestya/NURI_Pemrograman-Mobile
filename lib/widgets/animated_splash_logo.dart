import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Icon NURI animasi — dibuat murni di Flutter (tanpa Figma).
/// 4 bagian terpisah, masing-masing punya animasi sendiri:
/// 1. Badge bundar  2. Huruf N  3. Daun  4. Titik nutrisi / "care spark"
class AnimatedSplashLogo extends StatefulWidget {
  final double size;
  final VoidCallback? onCompleted;

  const AnimatedSplashLogo({
    super.key,
    this.size = 140,
    this.onCompleted,
  });

  @override
  State<AnimatedSplashLogo> createState() => _AnimatedSplashLogoState();
}

class _AnimatedSplashLogoState extends State<AnimatedSplashLogo>
    with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _pulse;

  late final Animation<double> _badgeOpacity;
  late final Animation<double> _badgeScale;
  late final Animation<double> _nOpacity;
  late final Animation<double> _nSlide;
  late final Animation<double> _leafOpacity;
  late final Animation<double> _leafRotate;
  late final Animation<double> _leafScale;
  late final Animation<double> _sparkOpacity;
  late final Animation<double> _sparkScale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 1) Badge
    _badgeOpacity = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
    );
    _badgeScale = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.0, 0.38, curve: Curves.easeOutBack),
      ),
    );

    // 2) Huruf N
    _nOpacity = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.28, 0.55, curve: Curves.easeOut),
    );
    _nSlide = Tween<double>(begin: 22, end: 0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.28, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    // 3) Daun
    _leafOpacity = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.48, 0.72, curve: Curves.easeOut),
    );
    _leafRotate = Tween<double>(begin: -0.7, end: 0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.48, 0.78, curve: Curves.easeOutBack),
      ),
    );
    _leafScale = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.48, 0.78, curve: Curves.easeOutBack),
      ),
    );

    // 4) Spark nutrisi
    _sparkOpacity = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.68, 0.90, curve: Curves.easeOut),
    );
    _sparkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.68, 0.95, curve: Curves.elasticOut),
      ),
    );

    _glow = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.10, 0.45, curve: Curves.easeOut),
    );

    _master.forward().whenComplete(() => widget.onCompleted?.call());
  }

  @override
  void dispose() {
    _master.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_master, _pulse]),
      builder: (context, _) {
        final pulse = 0.88 + (_pulse.value * 0.12);

        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Glow
              Opacity(
                opacity: (_glow.value * 0.5 * pulse).clamp(0.0, 1.0),
                child: Container(
                  width: s * 0.88,
                  height: s * 0.88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 32 * pulse,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // === 1. BADGE ===
              Opacity(
                opacity: _badgeOpacity.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _badgeScale.value,
                  child: NuriLogoBadge(size: s),
                ),
              ),

              // === 2. HURUF N ===
              Opacity(
                opacity: _nOpacity.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, _nSlide.value),
                  child: NuriLogoLetter(size: s),
                ),
              ),

              // === 3. DAUN ===
              Opacity(
                opacity: _leafOpacity.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _leafScale.value,
                  child: Transform.rotate(
                    angle: _leafRotate.value,
                    alignment: const Alignment(0.2, 0.4),
                    child: NuriLogoLeaf(size: s),
                  ),
                ),
              ),

              // === 4. SPARK ===
              Opacity(
                opacity: _sparkOpacity.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _sparkScale.value,
                  child: NuriLogoSpark(size: s),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian-bagian icon NURI (bisa dipakai ulang di login / app bar)
// ---------------------------------------------------------------------------

class NuriLogoBadge extends StatelessWidget {
  final double size;
  final bool white;

  const NuriLogoBadge({super.key, required this.size, this.white = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BadgePainter(white: white),
    );
  }
}

class NuriLogoLetter extends StatelessWidget {
  final double size;
  final bool onDark;

  const NuriLogoLetter({super.key, required this.size, this.onDark = true});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LetterNPainter(onDark: onDark),
    );
  }
}

class NuriLogoLeaf extends StatelessWidget {
  final double size;
  final bool white;

  const NuriLogoLeaf({super.key, required this.size, this.white = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LeafPainter(white: white),
    );
  }
}

class NuriLogoSpark extends StatelessWidget {
  final double size;
  final bool white;

  const NuriLogoSpark({super.key, required this.size, this.white = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparkPainter(white: white),
    );
  }
}

/// Logo NURI lengkap (statis) — untuk login / header.
class NuriLogo extends StatelessWidget {
  final double size;
  final bool white;

  const NuriLogo({super.key, this.size = 88, this.white = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          NuriLogoBadge(size: size, white: white),
          // Di badge putih: huruf & aksen pakai warna brand (bukan putih)
          NuriLogoLetter(size: size, onDark: !white),
          NuriLogoLeaf(size: size, white: false),
          NuriLogoSpark(size: size, white: false),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

class _BadgePainter extends CustomPainter {
  final bool white;

  _BadgePainter({required this.white});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;

    if (white) {
      canvas.drawCircle(c, r, Paint()..color = Colors.white);
      return;
    }

    final rect = Rect.fromCircle(center: c, radius: r);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00D4B8), Color(0xFF00A896), Color(0xFF028090)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawCircle(c, r, paint);

    // soft inner highlight
    canvas.drawCircle(
      Offset(c.dx - r * 0.25, c.dy - r * 0.28),
      r * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _BadgePainter oldDelegate) =>
      oldDelegate.white != white;
}

class _LetterNPainter extends CustomPainter {
  final bool onDark;

  _LetterNPainter({required this.onDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final color = onDark ? Colors.white : AppColors.primaryDark;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.095
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Stylized N
    final path = Path()
      ..moveTo(w * 0.32, h * 0.68)
      ..lineTo(w * 0.32, h * 0.32)
      ..lineTo(w * 0.68, h * 0.68)
      ..lineTo(w * 0.68, h * 0.32);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LetterNPainter oldDelegate) =>
      oldDelegate.onDark != onDark;
}

class _LeafPainter extends CustomPainter {
  final bool white;

  _LeafPainter({required this.white});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: white
            ? [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.7),
              ]
            : const [Color(0xFF8FE3A1), Color(0xFF2EAD5B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.55, h * 0.45, w * 0.4, h * 0.4));

    // Leaf di kanan bawah huruf N
    final leaf = Path()
      ..moveTo(w * 0.62, h * 0.58)
      ..quadraticBezierTo(w * 0.88, h * 0.48, w * 0.82, h * 0.78)
      ..quadraticBezierTo(w * 0.70, h * 0.74, w * 0.62, h * 0.58);
    canvas.drawPath(leaf, paint);

    // Vein
    final vein = Paint()
      ..color = white
          ? Colors.white.withValues(alpha: 0.5)
          : const Color(0xFF1B7A3D).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.64, h * 0.60),
      Offset(w * 0.78, h * 0.70),
      vein,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.white != white;
}

class _SparkPainter extends CustomPainter {
  final bool white;

  _SparkPainter({required this.white});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final color = white ? Colors.white : const Color(0xFFFFD54F);

    // 3 titik "nutrisi" di kiri atas
    final dots = [
      Offset(w * 0.28, h * 0.26),
      Offset(w * 0.22, h * 0.34),
      Offset(w * 0.34, h * 0.22),
    ];
    final radii = [w * 0.035, w * 0.022, w * 0.018];

    for (var i = 0; i < dots.length; i++) {
      canvas.drawCircle(
        dots[i],
        radii[i],
        Paint()..color = color.withValues(alpha: i == 0 ? 1 : 0.85),
      );
    }

    // tiny plus (kesehatan)
    final plusPaint = Paint()
      ..color = color
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    final p = Offset(w * 0.74, h * 0.28);
    canvas.drawLine(p + Offset(-w * 0.03, 0), p + Offset(w * 0.03, 0), plusPaint);
    canvas.drawLine(p + Offset(0, -w * 0.03), p + Offset(0, w * 0.03), plusPaint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.white != white;
}

/// Teks brand animasi (fade + naik).
class AnimatedBrandText extends StatelessWidget {
  final AnimationController controller;
  final String title;
  final String tagline;

  const AnimatedBrandText({
    super.key,
    required this.controller,
    required this.title,
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final titleAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOutCubic),
    );
    final tagAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.68, 0.95, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          children: [
            Opacity(
              opacity: titleAnim.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - titleAnim.value)),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Opacity(
              opacity: tagAnim.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - tagAnim.value)),
                child: Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textGrey,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SplashOrbitRing extends StatelessWidget {
  final AnimationController pulse;
  final double size;

  const SplashOrbitRing({
    super.key,
    required this.pulse,
    this.size = 168,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return CustomPaint(
          size: Size(size, size),
          painter: _OrbitPainter(progress: pulse.value),
        );
      },
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;

  _OrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final arc = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0),
          AppColors.primaryLight,
          AppColors.primary,
        ],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.35,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
