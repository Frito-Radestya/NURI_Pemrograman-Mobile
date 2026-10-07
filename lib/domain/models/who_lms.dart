import 'dart:math' as math;

import 'sex.dart';

/// Satu titik tabel LMS WHO (PRD Bagian 6).
///
/// Untuk tinggi/panjang badan menurut umur, WHO menerbitkan LMS harian
/// (0\u20131856 hari) sehingga [ageDays] adalah umur dalam hari.
class LmsPoint {
  const LmsPoint({
    required this.ageDays,
    required this.l,
    required this.m,
    required this.s,
  });

  final int ageDays;
  final double l;
  final double m;
  final double s;

  /// Nilai X (cm) untuk z tertentu: `X = M\u00b7(1 + L\u00b7S\u00b7z)^(1/L)`.
  double valueForZ(double z) {
    if (l.abs() < 1e-9) {
      return m * math.exp(s * z);
    }
    return m * math.pow(1 + l * s * z, 1 / l).toDouble();
  }

  /// Rumus z-score LMS: `z = ((X/M)^L \u2212 1) / (L\u00b7S)`.
  double zScoreFor(double x) {
    if (l.abs() < 1e-9) {
      return math.log(x / m) / s;
    }
    return ((math.pow(x / m, l) - 1) / (l * s)).toDouble();
  }
}

/// Tabel LMS tinggi/panjang badan menurut umur (WHO Child Growth Standards 2006).
class WhoLmsTable {
  const WhoLmsTable({
    required this.refVersion,
    required this.boys,
    required this.girls,
  });

  final String refVersion;
  final List<LmsPoint> boys;
  final List<LmsPoint> girls;

  List<LmsPoint> forSex(Sex sex) => sex == Sex.lakiLaki ? boys : girls;

  int get maxDays => forSex(Sex.lakiLaki).last.ageDays;

  /// Rata-rata panjang bulan (hari) menurut WHO.
  static const double daysPerMonth = 30.4375;

  /// Titik LMS pada umur (hari) tertentu, interpolasi linear antar hari.
  LmsPoint atDays(Sex sex, num days) {
    final List<LmsPoint> points = forSex(sex);
    if (points.isEmpty) {
      return const LmsPoint(ageDays: 0, l: 1, m: 50, s: 0.04);
    }
    final double clamped = days
        .toDouble()
        .clamp(points.first.ageDays.toDouble(), points.last.ageDays.toDouble())
        .toDouble();
    final int i = clamped.floor();
    final int j = clamped.ceil();
    if (i == j) return points[_indexOf(points, i)];
    final double t = clamped - i;
    final LmsPoint a = points[_indexOf(points, i)];
    final LmsPoint b = points[_indexOf(points, j)];
    return LmsPoint(
      ageDays: i,
      l: _lerp(a.l, b.l, t),
      m: _lerp(a.m, b.m, t),
      s: _lerp(a.s, b.s, t),
    );
  }

  int _indexOf(List<LmsPoint> points, int day) {
    // Tabel harian padat: indeks sama dengan hari, dengan pengaman rentang.
    if (points.first.ageDays == 0 &&
        points.length > day &&
        points[day].ageDays == day) {
      return day;
    }
    for (int i = 0; i < points.length; i++) {
      if (points[i].ageDays == day) return i;
    }
    return points.length - 1;
  }

  /// Titik LMS pada umur (bulan) tertentu untuk kurva (F6).
  LmsPoint at(Sex sex, int month) => atDays(sex, month * daysPerMonth);

  /// Nilai cm untuk z tertentu pada umur (bulan) tertentu (dipakai kurva).
  double valueForZ(Sex sex, int month, double z) =>
      at(sex, month).valueForZ(z);

  /// Nilai cm untuk z tertentu pada umur (hari) tertentu.
  double valueForZDays(Sex sex, num days, double z) =>
      atDays(sex, days).valueForZ(z);

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
