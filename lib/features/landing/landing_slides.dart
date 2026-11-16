import 'package:flutter/material.dart';

import 'landing_models.dart';
import 'landing_painters.dart';

class LandingAnimatedSlide extends StatelessWidget {
  const LandingAnimatedSlide({super.key, required this.slide});

  final LandingSlideModel slide;

  @override
  Widget build(BuildContext context) {
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
              child: LandingSlideIllustration(slideType: slide.slideType),
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
                    color: LandingColors.leafGreen.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    slide.badge.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: LandingColors.forestGreen,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: LandingColors.deepGreen,
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
                    color: LandingColors.charcoal.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LandingSlideIllustration extends StatelessWidget {
  const LandingSlideIllustration({super.key, required this.slideType});

  final int slideType;

  @override
  Widget build(BuildContext context) {
    if (slideType == 1) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 204,
            height: 204,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LandingColors.forestGreen.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 164,
            height: 164,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LandingColors.leafGreen.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 26,
            right: 34,
            child: Transform.rotate(
              angle: 0.4,
              child: const Icon(
                Icons.eco_rounded,
                size: 34,
                color: LandingColors.leafGreen,
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 34,
            child: Transform.rotate(
              angle: -0.6,
              child: const Icon(
                Icons.eco_rounded,
                size: 30,
                color: LandingColors.forestGreen,
              ),
            ),
          ),
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
      return CustomPaint(
        size: const Size(320, 235),
        painter: Slide2WhoChartPainter(),
      );
    } else {
      return CustomPaint(
        size: const Size(320, 235),
        painter: Slide3PlatePainter(),
      );
    }
  }
}
