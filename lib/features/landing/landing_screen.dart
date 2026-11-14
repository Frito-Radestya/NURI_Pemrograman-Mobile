import 'dart:async';

import 'package:flutter/material.dart';
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
  final PageController _pageController = PageController(viewportFraction: 0.91);
  Timer? _timer;
  int _page = 0;

  static const _slides = [
    _LandingSlide(
      asset: 'assets/images/hero_family.jpg',
      tag: 'Ibu & Balita',
      caption: 'Tumbuh kembang terpantau, hati lebih tenang.',
      tint: Color(0xFF145C45),
    ),
    _LandingSlide(
      asset: 'assets/images/hero_baby.jpg',
      tag: '1000 Hari Pertama',
      caption: 'Setiap sentimeter berarti. Pantau dari hari pertama.',
      tint: Color(0xFF0E4332),
    ),
    _LandingSlide(
      asset: 'assets/images/food_plate.jpg',
      tag: 'Gizi Harian',
      caption: 'Catat makan anak dengan porsi yang lebih tepat.',
      tint: Color(0xFF263B32),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_page + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openLogin([UserRole? role]) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LoginScreen(initialRole: role)));
  }

  void _skip() {
    ref.read(appControllerProvider.notifier).setLandingSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 6),
                child: Row(
                  children: [
                    const NuriLogo(),
                    const Spacer(),
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.muted,
                        minimumSize: const Size(48, 44),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 232,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              slide.asset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(color: AppColors.primarySoft),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    slide.tint.withValues(alpha: 0.24),
                                    slide.tint.withValues(alpha: 0.9),
                                  ],
                                  stops: const [0.15, 0.55, 1],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.36),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  slide.tag,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: Text(
                                slide.caption,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.white,
                                  fontSize: 19,
                                  height: 1.24,
                                  letterSpacing: -0.2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final active = index == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.line,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 28,
                          height: 1.14,
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                        children: [
                          TextSpan(text: 'Ibu Sehat,\n'),
                          TextSpan(
                            text: 'Awal Generasi Cemerlang',
                            style: TextStyle(color: AppColors.freshGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pantau kehamilan, tumbuh kembang balita, dan asupan gizi harian dalam satu tempat.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        _CredentialItem(
                          icon: Icons.public_rounded,
                          text: 'Standar WHO',
                        ),
                        _CredentialItem(
                          icon: Icons.menu_book_rounded,
                          text: 'AKG 2019',
                        ),
                        _CredentialItem(
                          icon: Icons.wifi_off_rounded,
                          text: 'Siap Offline',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pilih Peran Anda',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    letterSpacing: -0.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _RoleCard(
                      icon: Icons.favorite_rounded,
                      accent: AppColors.deepForest,
                      tint: AppColors.softMint,
                      title: 'Saya Ibu / Keluarga',
                      subtitle:
                          'Pantau kehamilan, tumbuh kembang, dan gizi harian',
                      onTap: () => _openLogin(UserRole.mother),
                    ),
                    const SizedBox(height: 10),
                    _RoleCard(
                      icon: Icons.groups_rounded,
                      accent: AppColors.freshGreen,
                      tint: AppColors.softMint,
                      title: 'Saya Kader Posyandu',
                      subtitle: 'Kelola sesi, sasaran, dan tindak lanjut',
                      onTap: () => _openLogin(UserRole.cadre),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => _openLogin(),
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: NuriDisclaimer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingSlide {
  const _LandingSlide({
    required this.asset,
    required this.tag,
    required this.caption,
    required this.tint,
  });

  final String asset;
  final String tag;
  final String caption;
  final Color tint;
}

class _CredentialItem extends StatelessWidget {
  const _CredentialItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.accent,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      shadow: true,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent, size: 22),
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
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}
