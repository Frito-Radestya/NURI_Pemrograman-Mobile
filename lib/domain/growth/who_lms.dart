import 'dart:convert';
import 'dart:math' as math;

import '../models.dart';

/// Satu baris LMS WHO. L dapat bernilai 0; rumus ditangani di kalkulator.
class LmsPoint {
  const LmsPoint(this.l, this.m, this.s);
  final double l;
  final double m;
  final double s;
}

/// Tabel WHO panjang/tinggi menurut umur, resolusi harian.
class WhoLmsTable {
  WhoLmsTable({
    required this.sex,
    required this.start,
    required this.step,
    required this.lms,
  });

  final Sex sex;
  final double start;
  final double step;
  final List<LmsPoint> lms;

  int get maxIndex => lms.length - 1;
  double get minAgeDays => start;
  double get maxAgeDays => start + step * maxIndex;

  /// Interpolasi linear antar titik harian. Titik di luar rentang di-clamp
  /// agar chart tetap dapat digambar; pemanggil menandai input di luar rentang.
  LmsPoint atAgeDays(double ageDays) {
    final raw = (ageDays - start) / step;
    final lower = raw.floor().clamp(0, maxIndex);
    final upper = raw.ceil().clamp(0, maxIndex);
    if (lower == upper) return lms[lower];
    final t = raw - lower;
    final a = lms[lower];
    final b = lms[upper];
    return LmsPoint(
      a.l + (b.l - a.l) * t,
      a.m + (b.m - a.m) * t,
      a.s + (b.s - a.s) * t,
    );
  }

  double valueAtZ(double ageDays, double z) {
    final p = atAgeDays(ageDays);
    if (p.l.abs() < 1e-9) {
      return p.m * math.exp(p.s * z);
    }
    final base = 1 + p.l * p.s * z;
    if (base <= 0) return p.m;
    return p.m * math.pow(base, 1 / p.l).toDouble();
  }

  factory WhoLmsTable.fromJson(Map<String, dynamic> json) {
    final rows = (json['lms'] as List? ?? const []);
    return WhoLmsTable(
      sex: Sex.fromStorage(json['sex'] as String?),
      start: parseDouble(json['start']) ?? 0,
      step: parseDouble(json['step']) ?? 1,
      lms: rows
          .whereType<List>()
          .map(
            (row) => LmsPoint(
              parseDouble(row.isNotEmpty ? row[0] : null) ?? 0,
              parseDouble(row.length > 1 ? row[1] : null) ?? 0,
              parseDouble(row.length > 2 ? row[2] : null) ?? 0,
            ),
          )
          .toList(),
    );
  }

  static WhoLmsTable fromJsonString(String source) =>
      WhoLmsTable.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

/// Kumpulan tabel referensi yang dibundel di aplikasi (F-13.6).
class WhoReference {
  const WhoReference({required this.boys, required this.girls});

  final WhoLmsTable boys;
  final WhoLmsTable girls;

  WhoLmsTable forSex(Sex sex) => sex == Sex.male ? boys : girls;

  static WhoReference? _instance;
  static WhoReference get instance {
    final value = _instance;
    if (value == null) {
      throw StateError(
        'WhoReference belum dimuat. Panggil WhoReference.load().',
      );
    }
    return value;
  }

  static bool get isLoaded => _instance != null;

  static void setInstance(WhoReference reference) => _instance = reference;
}
