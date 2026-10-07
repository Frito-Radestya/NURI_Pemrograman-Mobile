/// Token jarak, radius, dan durasi NURI.
class AppDimens {
  AppDimens._();

  // Jarak layar standar.
  static const double screenPadding = 20;
  static const double screenPaddingLg = 24;

  // Radius.
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  // Jarak antar-elemen.
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 24;
  static const double gap2Xl = 32;

  // Tinggi komponen.
  static const double buttonHeight = 56;
  static const double fieldHeight = 58;
  static const double navHeight = 72;

  // Durasi animasi.
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 560);
}
