import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../auth/onboarding_screens.dart';

class _ObColors {
  static const Color forestGreen = Color(0xFF1F602E);
  static const Color leafGreen = Color(0xFF44A74F);
  static const Color deepGreen = Color(0xFF0B3210);
  static const Color charcoal = Color(0xFF1B1B1B);
  static const Color naturalWhite = Color(0xFFF2F7F1);
}

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; // 0, 1, 2 = Slides 1..3; 3 = Pilih Peran
  UserRole _selectedRole = UserRole.mother;

  static const List<_SlideModel> _slides = [
    _SlideModel(
      badge: '01 — Kenali NURI',
      title: 'Setiap Anak Berhak Tumbuh Sehat',
      desc:
          'NURI hadir membantu ibu dan keluarga memantau kesehatan, pertumbuhan, serta kebutuhan nutrisi anak.',
      slideType: 1,
    ),
    _SlideModel(
      badge: '02 — Pantau Pertumbuhan',
      title: 'Pantau Setiap Tahap Pertumbuhannya',
      desc:
          'Catat tinggi dan berat badan anak, lalu pahami perkembangan pertumbuhannya berdasarkan standar WHO.',
      slideType: 2,
    ),
    _SlideModel(
      badge: '03 — Penuhi Nutrisi',
      title: 'Nutrisi Tepat, Tumbuh Lebih Optimal',
      desc:
          'Catat makanan harian dan dapatkan informasi nutrisi untuk mendukung kebutuhan gizi anak.',
      slideType: 3,
    ),
  ];

  void _goToSlide(int idx) {
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextSlide() {
    if (_currentIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _confirmRole() {
    ref.read(appControllerProvider.notifier).setLandingSeen();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(initialRole: _selectedRole),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRolePage = _currentIndex == 3;

    return Scaffold(
      backgroundColor: _ObColors.naturalWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header: Brand Badge + Lewati / Kembali (exact match onboarding.html)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _ObColors.forestGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/nuri_logo_mark.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.spa_rounded,
                            size: 18,
                            color: _ObColors.forestGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'NURI',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: _ObColors.deepGreen,
                        ),
                      ),
                    ],
                  ),
                  if (!isRolePage)
                    TextButton(
                      onPressed: () => _goToSlide(3),
                      style: TextButton.styleFrom(
                        foregroundColor: _ObColors.forestGreen,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Lewati'),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => _goToSlide(2),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: _ObColors.forestGreen,
                      ),
                      label: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _ObColors.forestGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Slide Stage (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  for (final slide in _slides) _buildAnimatedSlide(slide),
                  _buildRoleSelectionPage(),
                ],
              ),
            ),

            // 3. Footer (Slide 1 - 3): Pagination Dots + Button Lanjut / Mulai Sekarang
            if (!isRolePage)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final bool isActive = i == _currentIndex;
                        return GestureDetector(
                          onTap: () => _goToSlide(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 28 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _ObColors.forestGreen
                                  : _ObColors.deepGreen.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentIndex == 2
                              ? _ObColors.deepGreen
                              : _ObColors.forestGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _nextSlide,
                        child: Text(
                          _currentIndex == 2 ? 'Mulai Sekarang →' : 'Lanjut →',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSlide(_SlideModel slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Anim-Pop Illustration Box (exact match .anim-pop CSS)
          TweenAnimationBuilder<double>(
            key: ValueKey('pop_${slide.slideType}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return Opacity(
                opacity: val.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - val) * 12),
                  child: Transform.scale(
                    scale: 0.88 + 0.12 * val,
                    child: child,
                  ),
                ),
              );
            },
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: _buildSlideIllustration(slide.slideType),
            ),
          ),
          const SizedBox(height: 14),
          // Anim-Up Text Box (exact match .anim-up CSS)
          TweenAnimationBuilder<double>(
            key: ValueKey('up_${slide.slideType}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Opacity(
                opacity: val.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - val) * 14),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _ObColors.leafGreen.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    slide.badge.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _ObColors.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _ObColors.deepGreen,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: _ObColors.charcoal.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideIllustration(int slideType) {
    if (slideType == 1) {
      // Exact match Slide 1 SVG from onboarding.html:
      // Concentric circles + 2 floating leaves + Mother & Baby emblem
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 204,
            height: 204,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _ObColors.forestGreen.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 164,
            height: 164,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _ObColors.leafGreen.withValues(alpha: 0.12),
            ),
          ),
          // Top right floating leaf
          Positioned(
            top: 26,
            right: 34,
            child: Transform.rotate(
              angle: 0.4,
              child: const Icon(
                Icons.eco_rounded,
                size: 34,
                color: _ObColors.leafGreen,
              ),
            ),
          ),
          // Bottom left floating leaf
          Positioned(
            bottom: 36,
            left: 34,
            child: Transform.rotate(
              angle: -0.6,
              child: const Icon(
                Icons.eco_rounded,
                size: 30,
                color: _ObColors.forestGreen,
              ),
            ),
          ),
          // Mother & Baby Emblem
          SizedBox(
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/images/nuri_logo_mark.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    } else if (slideType == 2) {
      // Exact match Slide 2 SVG from onboarding.html:
      // WHO Growth Chart curve + Stadiometer ruler bar + Floating badge
      return CustomPaint(
        size: const Size(320, 235),
        painter: _Slide2WhoChartPainter(),
      );
    } else {
      // Exact match Slide 3 SVG from onboarding.html:
      // Divided 4-quadrant nutrition plate with vegetables, fruit, fish/protein, rice
      return CustomPaint(
        size: const Size(320, 235),
        painter: _Slide3PlatePainter(),
      );
    }
  }

  Widget _buildRoleSelectionPage() {
    final bool isMother = _selectedRole == UserRole.mother;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: TweenAnimationBuilder<double>(
        key: const ValueKey('role_page_anim'),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) {
          return Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - val) * 14),
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _ObColors.leafGreen.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                '04 — PILIH PERAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _ObColors.forestGreen,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mulai Perjalanan Bersama NURI',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _ObColors.deepGreen,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih peran untuk mendapatkan pengalaman aplikasi yang sesuai kebutuhanmu.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: _ObColors.charcoal.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 18),

            // Card 1: Saya Ibu / Keluarga
            _buildRoleCard(
              role: UserRole.mother,
              title: 'Saya Ibu / Keluarga',
              subtitle:
                  'Pantau grafik pertumbuhan standar WHO, catat makanan harian, dan cek kecukupan nutrisi anak.',
              iconWidget: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _ObColors.leafGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/images/nuri_logo_mark.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Card 2: Saya Kader Posyandu
            _buildRoleCard(
              role: UserRole.cadre,
              title: 'Saya Kader Posyandu',
              subtitle:
                  'Catat pengukuran antropometri balita, skrining cepat risiko stunting, dan kelola data Posyandu.',
              iconWidget: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _ObColors.leafGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: _ObColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ObColors.forestGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: _confirmRole,
                child: Text(
                  isMother
                      ? 'Lanjutkan sebagai Ibu / Keluarga →'
                      : 'Lanjutkan sebagai Kader Posyandu →',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required Widget iconWidget,
  }) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedRole = role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? _ObColors.forestGreen
                : _ObColors.forestGreen.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _ObColors.forestGreen.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _ObColors.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: _ObColors.charcoal.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _ObColors.forestGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? _ObColors.forestGreen
                      : const Color(0xFFBFCABA),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideModel {
  final String badge;
  final String title;
  final String desc;
  final int slideType;

  const _SlideModel({
    required this.badge,
    required this.title,
    required this.desc,
    required this.slideType,
  });
}

/// CustomPainter for Slide 2: Exact replica of onboarding_slide_02_pantau_pertumbuhan.svg
class _Slide2WhoChartPainter extends CustomPainter {
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
      Paint()..color = _ObColors.forestGreen.withValues(alpha: 0.07),
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
        ..color = _ObColors.forestGreen
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
      Paint()..color = _ObColors.leafGreen.withValues(alpha: 0.2),
    );

    // Main curve
    final curvePath = Path()
      ..moveTo(92, 170)
      ..quadraticBezierTo(175, 132, 266, 84);
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = _ObColors.forestGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Data points
    final dotPaint = Paint()..color = _ObColors.forestGreen;
    canvas.drawCircle(const Offset(92, 170), 4, dotPaint);
    canvas.drawCircle(const Offset(148, 142), 4.5, dotPaint);
    canvas.drawCircle(const Offset(206, 113), 4.5, dotPaint);
    canvas.drawCircle(
      const Offset(266, 84),
      6,
      Paint()..color = _ObColors.leafGreen,
    );

    // Left vertical stadiometer ruler
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 22, 34, 190),
        const Radius.circular(10),
      ),
      Paint()..color = _ObColors.deepGreen,
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
      Paint()..color = _ObColors.leafGreen,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter for Slide 3: Exact replica of onboarding_slide_03_penuhi_nutrisi.svg
class _Slide3PlatePainter extends CustomPainter {
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
      Paint()..color = _ObColors.leafGreen.withValues(alpha: 0.10),
    );

    // Plate rim
    canvas.drawCircle(center, 76, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      76,
      Paint()
        ..color = _ObColors.forestGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Inner plate well
    canvas.drawCircle(center, 60, Paint()..color = _ObColors.naturalWhite);
    canvas.drawCircle(
      center,
      60,
      Paint()
        ..color = _ObColors.leafGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Quadrant dividers
    final divPaint = Paint()
      ..color = _ObColors.forestGreen.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(160, 60), const Offset(160, 180), divPaint);
    canvas.drawLine(const Offset(100, 120), const Offset(220, 120), divPaint);

    // Top-left: Vegetables (broccoli/greens)
    canvas.drawCircle(
      const Offset(128, 90),
      12,
      Paint()..color = _ObColors.forestGreen,
    );
    canvas.drawCircle(
      const Offset(140, 86),
      10,
      Paint()..color = _ObColors.leafGreen,
    );
    canvas.drawCircle(
      const Offset(134, 98),
      9,
      Paint()..color = _ObColors.leafGreen,
    );

    // Top-right: Fruit
    canvas.drawCircle(
      const Offset(188, 94),
      14,
      Paint()..color = _ObColors.leafGreen,
    );

    // Bottom-left: Protein
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(132, 148), width: 30, height: 22),
      Paint()..color = _ObColors.forestGreen,
    );
    canvas.drawCircle(
      const Offset(130, 148),
      6,
      Paint()..color = _ObColors.leafGreen,
    );

    // Bottom-right: Carbs / Rice bowl
    final bowlPath = Path()
      ..moveTo(172, 150)
      ..lineTo(204, 150)
      ..quadraticBezierTo(188, 164, 172, 150)
      ..close();
    canvas.drawPath(bowlPath, Paint()..color = _ObColors.leafGreen);
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(188, 150), width: 28, height: 20),
      3.14,
      3.14,
      true,
      Paint()..color = _ObColors.deepGreen,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
