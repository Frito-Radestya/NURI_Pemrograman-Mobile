import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../auth/onboarding_screens.dart';
import 'landing_models.dart';
import 'landing_role_selection.dart';
import 'landing_slides.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; // 0, 1, 2 = Slides 1..3; 3 = Pilih Peran
  UserRole _selectedRole = UserRole.mother;

  static const List<LandingSlideModel> _slides = [
    LandingSlideModel(
      badge: '01 — Kenali NURI',
      title: 'Setiap Anak Berhak Tumbuh Sehat',
      desc: 'NURI hadir membantu ibu dan keluarga memantau kesehatan, pertumbuhan, serta kebutuhan nutrisi anak.',
      slideType: 1,
    ),
    LandingSlideModel(
      badge: '02 — Pantau Pertumbuhan',
      title: 'Pantau Setiap Tahap Pertumbuhannya',
      desc: 'Catat tinggi dan berat badan anak, lalu pahami perkembangan pertumbuhannya berdasarkan standar WHO.',
      slideType: 2,
    ),
    LandingSlideModel(
      badge: '03 — Penuhi Nutrisi',
      title: 'Nutrisi Tepat, Tumbuh Lebih Optimal',
      desc: 'Catat makanan harian dan dapatkan informasi nutrisi untuk mendukung kebutuhan gizi anak.',
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
      backgroundColor: LandingColors.naturalWhite,
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
                            color: LandingColors.forestGreen.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/nuri_logo_mark.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.spa_rounded,
                            size: 18,
                            color: LandingColors.forestGreen,
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
                          color: LandingColors.deepGreen,
                        ),
                      ),
                    ],
                  ),
                  if (!isRolePage)
                    TextButton(
                      onPressed: () => _goToSlide(3),
                      style: TextButton.styleFrom(
                        foregroundColor: LandingColors.forestGreen,
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
                        color: LandingColors.forestGreen,
                      ),
                      label: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: LandingColors.forestGreen,
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
                  for (final slide in _slides)
                    LandingAnimatedSlide(slide: slide),
                  LandingRoleSelectionPage(
                    selectedRole: _selectedRole,
                    onSelectRole: (role) =>
                        setState(() => _selectedRole = role),
                    onConfirmRole: _confirmRole,
                  ),
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
                                  ? LandingColors.forestGreen
                                  : LandingColors.deepGreen.withValues(
                                      alpha: 0.25,
                                    ),
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
                              ? LandingColors.deepGreen
                              : LandingColors.forestGreen,
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
}
