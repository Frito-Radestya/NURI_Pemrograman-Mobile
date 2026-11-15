import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../auth/onboarding_screens.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  UserRole _selectedRole = UserRole.mother;

  static const List<_SlideData> _slides = [
    _SlideData(
      badge: '01 — Kenali NURI',
      title: 'Setiap Anak Berhak Tumbuh Sehat',
      description:
          'NURI hadir membantu ibu dan keluarga memantau kesehatan, pertumbuhan, serta kebutuhan nutrisi anak.',
      icon: Icons.family_restroom_rounded,
    ),
    _SlideData(
      badge: '02 — Pantau Pertumbuhan',
      title: 'Pantau Setiap Tahap Pertumbuhannya',
      description:
          'Catat tinggi dan berat badan anak, lalu pahami perkembangan pertumbuhannya berdasarkan standar WHO.',
      icon: Icons.auto_graph_rounded,
    ),
    _SlideData(
      badge: '03 — Penuhi Nutrisi',
      title: 'Nutrisi Tepat, Tumbuh Lebih Optimal',
      description:
          'Catat makanan harian dan dapatkan informasi nutrisi untuk mendukung kebutuhan gizi anak cegah stunting.',
      icon: Icons.restaurant_rounded,
    ),
  ];

  void _skipToRoleSelection() {
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextSlide() {
    if (_currentIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar: Logo NURI Bulat + Lewati / Kembali
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const NuriLogo(compact: false),
                  if (!isRolePage)
                    TextButton(
                      onPressed: _skipToRoleSelection,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Lewati'),
                    )
                  else
                    TextButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Kembali'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Body PageView: Slide 1..3 & Slide 4 Pilih Peran
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  for (int i = 0; i < _slides.length; i++)
                    _buildSlide(i, _slides[i]),
                  _buildRoleSelectionPage(),
                ],
              ),
            ),

            // 3. Footer Pagination & Next Button (Slide 1..3)
            if (!isRolePage)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final bool isActive = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 7,
                          width: isActive ? 24 : 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    NuriButton(
                      label: _currentIndex == 2 ? 'Mulai Sekarang' : 'Lanjut',
                      icon: Icons.arrow_forward_rounded,
                      height: 52,
                      onPressed: _nextSlide,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(int index, _SlideData slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 14),
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.line),
              boxShadow: AppShadows.card,
            ),
            child: _buildIllustration(index),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              slide.badge,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIllustration(int index) {
    if (index == 0) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softMint.withValues(alpha: 0.6),
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x180D631B),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/nuri_logo_mark.png',
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            top: 20,
            right: 40,
            child: Icon(
              Icons.eco_rounded,
              size: 28,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      );
    } else if (index == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.straighten_rounded, color: AppColors.secondaryFixed, size: 24),
                Text('85 cm', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                Text('75 cm', style: TextStyle(color: Colors.white70, fontSize: 9)),
                Text('65 cm', style: TextStyle(color: Colors.white54, fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grafik Pertumbuhan WHO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.auto_graph_rounded,
                      size: 64,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  Text(
                    '✓ Tinggi & Berat Terpantau',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: const [
          _FoodPill(icon: Icons.eco_rounded, label: 'Sayuran Hijau'),
          _FoodPill(icon: Icons.apple_rounded, label: 'Buah Segar'),
          _FoodPill(icon: Icons.set_meal_rounded, label: 'Protein Hewani'),
          _FoodPill(icon: Icons.rice_bowl_rounded, label: 'Gizi Seimbang'),
        ],
      );
    }
  }

  Widget _buildRoleSelectionPage() {
    final bool isMother = _selectedRole == UserRole.mother;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Text(
              '04 — Pilih Peran Anda',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mulai Perjalanan Bersama NURI',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih peran untuk mendapatkan pengalaman aplikasi yang sesuai kebutuhanmu.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Card 1: Saya Ibu / Keluarga
          _buildRoleCard(
            role: UserRole.mother,
            title: 'Saya Ibu / Keluarga',
            subtitle:
                'Pantau grafik pertumbuhan standar WHO, catat makanan harian, dan cek kecukupan nutrisi anak.',
            iconWidget: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLow,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CTA Button matching image 1
          NuriButton(
            label: isMother
                ? 'Lanjutkan sebagai Ibu / Keluarga →'
                : 'Lanjutkan sebagai Kader Posyandu →',
            height: 52,
            onPressed: _confirmRole,
          ),
          const SizedBox(height: 12),
        ],
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.line,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLow,
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Custom Radio Indicator (matching image 1)
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
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

class _SlideData {
  final String badge;
  final String title;
  final String description;
  final IconData icon;

  const _SlideData({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _FoodPill extends StatelessWidget {
  const _FoodPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
