// ============================================================================
// NURI — 3-Slide Onboarding + Halaman Pemilihan Peran (Zero Form Friction UX)
// File: lib/features/onboarding/nuri_onboarding_screen.dart
//
// Struktur Onboarding NURI:
// - Slide 01 (Kenali NURI): "Setiap Anak Berhak Tumbuh Sehat"
// - Slide 02 (Pantau Pertumbuhan): "Pantau Setiap Tahap Pertumbuhannya"
// - Slide 03 (Penuhi Nutrisi): "Nutrisi Tepat, Tumbuh Lebih Optimal" (CTA: Mulai Sekarang)
// - Halaman 04 (Pilih Peran): "Mulai Perjalanan Bersama NURI"
//     * Saya Ibu / Keluarga
//     * Saya Kader Posyandu
// ============================================================================
import 'package:flutter/material.dart';

enum NuriUserRole {
  ibuKeluarga,
  kaderPosyandu,
}

class NuriOnboardingColors {
  static const Color forestGreen  = Color(0xFF1F602E);
  static const Color leafGreen    = Color(0xFF44A74F);
  static const Color deepGreen    = Color(0xFF0B3210);
  static const Color charcoal     = Color(0xFF1B1B1B);
  static const Color naturalWhite = Color(0xFFF2F7F1);
}

class NuriOnboardingSlideModel {
  final String code;
  final String title;
  final String description;
  final int slideType; // 1 = Ibu & Anak + Daun, 2 = Grafik WHO, 3 = Nutrisi

  const NuriOnboardingSlideModel({
    required this.code,
    required this.title,
    required this.description,
    required this.slideType,
  });
}

class NuriOnboardingScreen extends StatefulWidget {
  final void Function(NuriUserRole selectedRole) onRoleConfirmed;

  const NuriOnboardingScreen({
    super.key,
    required this.onRoleConfirmed,
  });

  @override
  State<NuriOnboardingScreen> createState() => _NuriOnboardingScreenState();
}

class _NuriOnboardingScreenState extends State<NuriOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; // 0..2 = Slide 1..3, 3 = Halaman 04 Pilih Peran
  NuriUserRole _selectedRole = NuriUserRole.ibuKeluarga;

  static const List<NuriOnboardingSlideModel> _slides = [
    NuriOnboardingSlideModel(
      code: '01 — Kenali NURI',
      title: 'Setiap Anak Berhak Tumbuh Sehat',
      description:
          'NURI hadir membantu ibu dan keluarga memantau kesehatan, pertumbuhan, serta kebutuhan nutrisi anak.',
      slideType: 1,
    ),
    NuriOnboardingSlideModel(
      code: '02 — Pantau Pertumbuhan',
      title: 'Pantau Setiap Tahap Pertumbuhannya',
      description:
          'Catat tinggi dan berat badan anak, lalu pahami perkembangan pertumbuhannya berdasarkan standar WHO.',
      slideType: 2,
    ),
    NuriOnboardingSlideModel(
      code: '03 — Penuhi Nutrisi',
      title: 'Nutrisi Tepat, Tumbuh Lebih Optimal',
      description:
          'Catat makanan harian dan dapatkan informasi nutrisi untuk mendukung kebutuhan gizi anak.',
      slideType: 3,
    ),
  ];

  void _skipToRoleSelection() {
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 420),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRolePage = _currentIndex == 3;

    return Scaffold(
      backgroundColor: NuriOnboardingColors.naturalWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header: Logo NURI Kecil + Tombol Lewati
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: NuriOnboardingColors.forestGreen
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: NuriOnboardingColors.forestGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'NURI',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: NuriOnboardingColors.deepGreen,
                        ),
                      ),
                    ],
                  ),
                  if (!isRolePage)
                    TextButton(
                      onPressed: _skipToRoleSelection,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: NuriOnboardingColors.forestGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: NuriOnboardingColors.forestGreen,
                      ),
                      label: const Text(
                        'Kembali',
                        style: TextStyle(
                          color: NuriOnboardingColors.forestGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Body: 3 Slide Pengenalan + Halaman 04 Pilih Peran
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  for (final slide in _slides) _buildOnboardingSlide(slide),
                  _buildRoleSelectionPage(),
                ],
              ),
            ),

            // 3. Footer (Khusus Slide 1 - 3): Pagination Indicator + Tombol Lanjut / Mulai Sekarang
            if (!isRolePage)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    // Pagination Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final bool isActive = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 28 : 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? NuriOnboardingColors.forestGreen
                                : NuriOnboardingColors.deepGreen
                                    .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    // Tombol Lanjut (Slide 1 & 2) -> Mulai Sekarang (Slide 3)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentIndex == 2
                              ? NuriOnboardingColors.deepGreen
                              : NuriOnboardingColors.forestGreen,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _nextSlide,
                        child: Text(
                          _currentIndex == 2 ? 'Mulai Sekarang' : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 15,
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

  Widget _buildOnboardingSlide(NuriOnboardingSlideModel slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi Animasi sesuai Slide (1, 2, atau 3)
          TweenAnimationBuilder<double>(
            key: ValueKey<int>(slide.slideType),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return Opacity(
                opacity: val.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + 0.15 * val,
                  child: child,
                ),
              );
            },
            child: Container(
              height: 240,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: NuriOnboardingColors.forestGreen.withValues(alpha: 0.15),
                ),
              ),
              child: _buildIllustrationContent(slide.slideType),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: NuriOnboardingColors.leafGreen.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              slide.code,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: NuriOnboardingColors.forestGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: NuriOnboardingColors.deepGreen,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: NuriOnboardingColors.charcoal.withValues(alpha: 0.82),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationContent(int slideType) {
    if (slideType == 1) {
      // Slide 1: Ibu & Anak muncul bertahap + Daun tumbuh
      return Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 74,
            backgroundColor:
                NuriOnboardingColors.leafGreen.withValues(alpha: 0.15),
          ),
          const Icon(
            Icons.family_restroom_rounded,
            size: 92,
            color: NuriOnboardingColors.forestGreen,
          ),
          const Positioned(
            top: 12,
            right: 28,
            child: Icon(
              Icons.eco_rounded,
              size: 36,
              color: NuriOnboardingColors.leafGreen,
            ),
          ),
        ],
      );
    } else if (slideType == 2) {
      // Slide 2: Indikator tinggi bergerak + Grafik pertumbuhan WHO
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 170,
            decoration: BoxDecoration(
              color: NuriOnboardingColors.deepGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.straighten_rounded,
              color: NuriOnboardingColors.leafGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 170,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NuriOnboardingColors.naturalWhite,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Standar Pertumbuhan WHO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: NuriOnboardingColors.deepGreen,
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.AutoGraph_rounded,
                      size: 72,
                      color: NuriOnboardingColors.forestGreen,
                    ),
                  ),
                  Text(
                    '✓ Tinggi & Berat Badan Terpantau',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NuriOnboardingColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Slide 3: Buah & Sayuran muncul satu per satu
      return Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: const [
          _NutritionChip(icon: Icons.eco_rounded, label: 'Sayuran Hijau'),
          _NutritionChip(icon: Icons.apple_rounded, label: 'Buah Segar'),
          _NutritionChip(icon: Icons.set_meal_rounded, label: 'Protein Hewani'),
          _NutritionChip(icon: Icons.rice_bowl_rounded, label: 'Gizi Seimbang'),
        ],
      );
    }
  }

  Widget _buildRoleSelectionPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: NuriOnboardingColors.leafGreen.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              '04 — Pilih Peran',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: NuriOnboardingColors.forestGreen,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mulai Perjalanan Bersama NURI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: NuriOnboardingColors.deepGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih peran untuk mendapatkan pengalaman aplikasi yang sesuai kebutuhanmu.',
            style: TextStyle(
              fontSize: 14,
              color: NuriOnboardingColors.charcoal.withValues(alpha: 0.82),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          // Pilihan 1: Saya Ibu / Keluarga
          _buildRoleOptionCard(
            role: NuriUserRole.ibuKeluarga,
            title: 'Saya Ibu / Keluarga',
            subtitle:
                'Pantau grafik pertumbuhan anak sesuai standar WHO dan catat makanan harian.',
            icon: Icons.favorite_rounded,
          ),
          const SizedBox(height: 14),

          // Pilihan 2: Saya Kader Posyandu
          _buildRoleOptionCard(
            role: NuriUserRole.kaderPosyandu,
            title: 'Saya Kader Posyandu',
            subtitle:
                'Kelola pencatatan penimbangan balita, skrining risiko stunting, dan data Posyandu.',
            icon: Icons.local_hospital_rounded,
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NuriOnboardingColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => widget.onRoleConfirmed(_selectedRole),
              child: Text(
                _selectedRole == NuriUserRole.ibuKeluarga
                    ? 'Lanjutkan sebagai Ibu / Keluarga'
                    : 'Lanjutkan sebagai Kader Posyandu',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOptionCard({
    required NuriUserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? NuriOnboardingColors.forestGreen
                : NuriOnboardingColors.forestGreen.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        NuriOnboardingColors.forestGreen.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: NuriOnboardingColors.leafGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: NuriOnboardingColors.forestGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: NuriOnboardingColors.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: NuriOnboardingColors.charcoal.withValues(alpha: 0.78),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: NuriOnboardingColors.forestGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NutritionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NuriOnboardingColors.naturalWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NuriOnboardingColors.forestGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: NuriOnboardingColors.forestGreen),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: NuriOnboardingColors.deepGreen,
            ),
          ),
        ],
      ),
    );
  }
}
