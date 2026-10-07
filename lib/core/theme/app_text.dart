import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala tipografi NURI (Plus Jakarta Sans).
class AppText {
  AppText._();

  static const String _family = 'PlusJakartaSans';

  static const TextStyle display = TextStyle(
    fontFamily: _family,
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _family,
    fontSize: 26,
    height: 1.2,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _family,
    fontSize: 21,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _family,
    fontSize: 15.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _family,
    fontSize: 14.5,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: _family,
    fontSize: 14.5,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _family,
    fontSize: 11.5,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.inkFaint,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _family,
    fontSize: 11.5,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.inkSoft,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _family,
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: AppColors.onDark,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: _family,
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.ink,
  );
}
