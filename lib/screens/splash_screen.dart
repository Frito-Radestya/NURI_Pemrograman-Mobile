import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_splash_logo.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _brandCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _bgCtrl;

  bool _logoDone = false;

  @override
  void initState() {
    super.initState();

    _brandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // Total splash ~3.4s lalu ke login
    Future.delayed(const Duration(milliseconds: 3400), _goLogin);
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _orbitCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (context, _) {
          final t = _bgCtrl.value;
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.8 + t * 0.4, -1),
                end: Alignment(0.8 - t * 0.3, 1),
                colors: [
                  Color.lerp(
                    const Color(0xFFE8F7FA),
                    const Color(0xFFD4F5F0),
                    t,
                  )!,
                  const Color(0xFFF5FBFC),
                  Colors.white,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Blob dekoratif bergerak lembut
                Positioned(
                  top: 80 + t * 20,
                  left: -40 + t * 30,
                  child: _softBlob(140, AppColors.primary.withValues(alpha: 0.08)),
                ),
                Positioned(
                  bottom: 120 - t * 25,
                  right: -30 - t * 20,
                  child: _softBlob(160, const Color(0xFF2F80ED).withValues(alpha: 0.07)),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  right: 40 + t * 12,
                  child: _softBlob(70, const Color(0xFF27AE60).withValues(alpha: 0.08)),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo + orbit ring
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SplashOrbitRing(pulse: _orbitCtrl, size: 172),
                            AnimatedSplashLogo(
                              size: 128,
                              onCompleted: () {
                                if (mounted) setState(() => _logoDone = true);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Brand text animasi terpisah
                      AnimatedBrandText(
                        controller: _brandCtrl,
                        title: 'NURI',
                        tagline: 'Nutrisi & Risiko Stunting\ndi Indonesia',
                      ),

                      const SizedBox(height: 12),

                      AnimatedOpacity(
                        opacity: _logoDone ? 1 : 0,
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          'Cegah stunting lebih dini',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Loading dots unik (bukan page indicator biasa)
                      _SplashLoadingDots(controller: _orbitCtrl),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _softBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _SplashLoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _SplashLoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (controller.value + i * 0.22) % 1.0;
            final bounce = (phase < 0.5)
                ? Curves.easeOut.transform(phase * 2)
                : Curves.easeIn.transform(1 - (phase - 0.5) * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8 + bounce * 4,
              height: 8 + bounce * 4,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(
                  alpha: 0.35 + bounce * 0.65,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        );
      },
    );
  }
}
