import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class NuriSplashScreen extends StatefulWidget {
  const NuriSplashScreen({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 1400),
  });

  final VoidCallback onFinished;
  final Duration duration;

  @override
  State<NuriSplashScreen> createState() => _NuriSplashScreenState();
}

class _NuriSplashScreenState extends State<NuriSplashScreen>
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

  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _baseAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.25, curve: Curves.easeOutBack),
    );
    _motherAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.08, 0.35, curve: Curves.easeOutCubic),
    );
    _crownAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.18, 0.45, curve: Curves.easeOutBack),
    );
    _sproutAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.24, 0.52, curve: Curves.elasticOut),
    );
    _babyAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.26, 0.56, curve: Curves.easeOutBack),
    );
    _medicalAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.40, 0.65, curve: Curves.easeOutBack),
    );

    _letterAnims = List.generate(4, (i) {
      final start = 0.50 + i * 0.04;
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, (start + 0.16).clamp(0.0, 1.0), curve: Curves.easeOutBack),
      );
    });

    _subtitleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.68, 0.88, curve: Curves.easeOutCubic),
    );
    _mottoAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.76, 0.98, curve: Curves.easeOutCubic),
    );

    _ctrl.forward().whenComplete(() {
      _finish();
    });
  }

  void _finish() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _buildLayer(String name) {
    return Image.asset(
      'assets/png_layers/$name',
      width: 330,
      height: 330,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['N', 'U', 'R', 'I'];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8F2),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _ctrl.stop();
            _finish();
          },
          child: Stack(
            children: [
              // Ambient soft circles in background
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryFixed.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  ),
                ),
              ),
              // Center animated composition
              Center(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) {
                    return SizedBox(
                      width: 330,
                      height: 330,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Lengkung Pelindung Dasar
                          Opacity(
                            opacity: _baseAnim.value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.72 + 0.28 * _baseAnim.value,
                              child: _buildLayer('comp_01_base.png'),
                            ),
                          ),
                          // 2. Siluet Ibu
                          Opacity(
                            opacity: _motherAnim.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, (1 - _motherAnim.value) * 18),
                              child: _buildLayer('comp_02_mother.png'),
                            ),
                          ),
                          // 3. Daun Mahkota Rambut
                          Opacity(
                            opacity: _crownAnim.value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.5 + 0.5 * _crownAnim.value,
                              child: _buildLayer('comp_03_crown_leaves.png'),
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
                                child: _buildLayer('comp_04_sprout_leaves.png'),
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
                              child: _buildLayer('comp_05_baby_cradle.png'),
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
                                child: _buildLayer('comp_06_medical_plus.png'),
                              ),
                            ),
                          ),
                          // 7. Huruf N-U-R-I Staggered
                          for (int i = 0; i < 4; i++)
                            Opacity(
                              opacity: _letterAnims[i].value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, (1 - _letterAnims[i].value) * 16),
                                child: _buildLayer('comp_07_letter_${letters[i]}.png'),
                              ),
                            ),
                          // 8. Sub-judul & Motto
                          Opacity(
                            opacity: _subtitleAnim.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, (1 - _subtitleAnim.value) * 10),
                              child: _buildLayer('comp_08_subtitle.png'),
                            ),
                          ),
                          Opacity(
                            opacity: _mottoAnim.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, (1 - _mottoAnim.value) * 10),
                              child: _buildLayer('comp_08_motto.png'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Skip label at bottom
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Sentuh layar untuk lewati',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.muted.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
