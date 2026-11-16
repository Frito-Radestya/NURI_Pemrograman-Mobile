import 'package:flutter/material.dart';

class LandingColors {
  static const Color forestGreen = Color(0xFF1F602E);
  static const Color leafGreen = Color(0xFF44A74F);
  static const Color deepGreen = Color(0xFF0B3210);
  static const Color charcoal = Color(0xFF1B1B1B);
  static const Color naturalWhite = Color(0xFFF2F7F1);
}

class LandingSlideModel {
  final String badge;
  final String title;
  final String desc;
  final int slideType;

  const LandingSlideModel({
    required this.badge,
    required this.title,
    required this.desc,
    required this.slideType,
  });
}

/// CustomPainter for Slide 2: Exact replica of onboarding_slide_02_pantau_pertumbuhan.svg
