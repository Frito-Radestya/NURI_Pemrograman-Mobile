import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/nuri_logo.dart';

/// Layar pembuka NURI (splash) dengan logo, tagline, dan versi.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2400), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goNext,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGlow),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: NuriEyebrowChip(
                    text: 'Standar Antropometri WHO & Kemenkes RI',
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lingkaran logo dengan glow lembut.
                      Container(
                        width: 172,
                        height: 172,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 40,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: const Color(0xFFD9E7D5).withValues(alpha: 0.9),
                              blurRadius: 60,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const NuriMark(size: 62),
                      ),
                      const SizedBox(height: 34),
                      Text(
                        'nuri',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 62,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.4,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'NUTRISI & PERTUMBUHAN ANAK',
                        style: AppText.label.copyWith(
                          color: AppColors.ink,
                          fontSize: 12.5,
                          letterSpacing: 3.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Sahabat pemantau gizi & tumbuh kembang\nbuah hati',
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(
                            color: AppColors.inkSoft,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 96,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.lineStrong.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Versi 1.0  •  Membantu Pencegahan Stunting',
                  style: AppText.caption.copyWith(
                    color: AppColors.inkFaint,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '•  Indonesia Sehat  •',
                  style: AppText.caption.copyWith(
                    color: AppColors.inkFaint,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
