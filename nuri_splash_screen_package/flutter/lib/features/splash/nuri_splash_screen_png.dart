// ============================================================================
// NURI — Animated Per-Component Splash Screen (SVG Version)
// File: lib/features/splash/nuri_splash_screen_svg.dart
// ============================================================================
import 'package:flutter/material.dart';

enum NuriSplashPreset {
  organicGrowth,
  heartbeatPulse,
  warmCradle,
  fastMinimal,
}

class NuriSplashScreenPng extends StatefulWidget {
  final VoidCallback onFinished;
  final NuriSplashPreset preset;

  const NuriSplashScreenPng({
    super.key,
    required this.onFinished,
    this.preset = NuriSplashPreset.organicGrowth,
  });

  @override
  State<NuriSplashScreenPng> createState() => _NuriSplashScreenPngState();
}

class _NuriSplashScreenPngState extends State<NuriSplashScreenPng>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _baseAnim;
  late final Animation<double> _motherAnim;
  late final Animation<double> _crownAnim;
  late final Animation<double> _sproutAnim;
  late final Animation<double> _babyAnim;
  late final Animation<double> _medicalAnim;
  late final List<Animation<double>> _letterAnims;
  late final Animation<double> _subtitleAnim;
  late final Animation<double> _mottoAnim;

  @override
  void initState() {
    super.initState();
    final isFast = widget.preset == NuriSplashPreset.fastMinimal;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: isFast ? 1600 : 2500),
    );

    _baseAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.22, curve: Curves.easeOutBack),
    );
    _motherAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.08, 0.32, curve: Curves.easeOutCubic),
    );
    _crownAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.18, 0.42, curve: Curves.easeOutBack),
    );
    _sproutAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.24, 0.50, curve: Curves.elasticOut),
    );
    _babyAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.26, 0.54, curve: Curves.easeOutBack),
    );
    _medicalAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.40, 0.64, curve: Curves.easeOutBack),
    );

    _letterAnims = List.generate(4, (i) {
      final start = 0.50 + i * 0.04;
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, start + 0.16, curve: Curves.easeOutBack),
      );
    });

    _subtitleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.68, 0.86, curve: Curves.easeOutCubic),
    );
    _mottoAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.76, 0.96, curve: Curves.easeOutCubic),
    );

    _ctrl.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 350), widget.onFinished);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _buildSvgLayer(String assetName) {
    return Image.asset(
      'assets/png_layers/${assetName.replaceAll('.svg', '.png')}',
      width: 340,
      height: 340,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['N', 'U', 'R', 'I'];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F2),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return SizedBox(
              width: 340,
              height: 340,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Lengkung Pelindung Dasar
                  Opacity(
                    opacity: _baseAnim.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.72 + 0.28 * _baseAnim.value,
                      child: _buildSvgLayer('comp_01_base.svg'),
                    ),
                  ),
                  // 2. Siluet Ibu
                  Opacity(
                    opacity: _motherAnim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - _motherAnim.value) * 18),
                      child: _buildSvgLayer('comp_02_mother.svg'),
                    ),
                  ),
                  // 3. Daun Mahkota Rambut
                  Opacity(
                    opacity: _crownAnim.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.5 + 0.5 * _crownAnim.value,
                      child: _buildSvgLayer('comp_03_crown_leaves.svg'),
                    ),
                  ),
                  // 4. Tunas Pertumbuhan Luar
                  Opacity(
                    opacity: _sproutAnim.value.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: (1 - _sproutAnim.value) * 0.65,
                      alignment: const Alignment(-0.18, -0.38),
                      child: Transform.scale(
                        scale: _sproutAnim.value.clamp(0.0, 1.25),
                        alignment: const Alignment(-0.18, -0.38),
                        child: _buildSvgLayer('comp_04_sprout_leaves.svg'),
                      ),
                    ),
                  ),
                  // 5. Siluet Bayi & Pelukan Ibu
                  Opacity(
                    opacity: _babyAnim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        (1 - _babyAnim.value) * 16,
                        (1 - _babyAnim.value) * 12,
                      ),
                      child: _buildSvgLayer('comp_05_baby_cradle.svg'),
                    ),
                  ),
                  // 6. Lencana Medis Plus (+)
                  Opacity(
                    opacity: _medicalAnim.value.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: (1 - _medicalAnim.value) * -1.5708,
                      alignment: const Alignment(0.0, 0.01),
                      child: Transform.scale(
                        scale: _medicalAnim.value.clamp(0.0, 1.3),
                        alignment: const Alignment(0.0, 0.01),
                        child: _buildSvgLayer('comp_06_medical_plus.svg'),
                      ),
                    ),
                  ),
                  // 7. Huruf N-U-R-I Staggered
                  for (int i = 0; i < 4; i++)
                    Opacity(
                      opacity: _letterAnims[i].value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, (1 - _letterAnims[i].value) * 16),
                        child: _buildSvgLayer('comp_07_letter_${letters[i]}.svg'),
                      ),
                    ),
                  // 8. Sub-judul & Motto
                  Opacity(
                    opacity: _subtitleAnim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - _subtitleAnim.value) * 10),
                      child: _buildSvgLayer('comp_08_subtitle.svg'),
                    ),
                  ),
                  Opacity(
                    opacity: _mottoAnim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - _mottoAnim.value) * 10),
                      child: _buildSvgLayer('comp_08_motto.svg'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
