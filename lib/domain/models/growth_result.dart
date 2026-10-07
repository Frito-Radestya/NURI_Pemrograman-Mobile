import 'growth_status.dart';
import 'measurement.dart';
import 'recommendation.dart';

/// Jenis kesalahan validasi pertumbuhan.
enum GrowthValidationKind {
  umurDiLuarRentang,
  nilaiTidakMasukAkal,
  tanggalTidakValid,
}

/// Kesalahan validasi yang harus ditampilkan dengan penyebab + langkah (PRD).
class GrowthValidationException implements Exception {
  const GrowthValidationException(this.kind, this.message, {this.hint});

  final GrowthValidationKind kind;
  final String message;
  final String? hint;

  @override
  String toString() => message;
}

/// Hasil skrining tumbuh kembang (PRD Bagian 6).
class GrowthResult {
  const GrowthResult({
    required this.zScore,
    required this.status,
    required this.ageMonths,
    required this.rawCm,
    required this.correctedCm,
    required this.method,
    required this.recommendedMethod,
    required this.methodAdjusted,
    required this.weightKg,
    required this.measuredOn,
    required this.refVersion,
    required this.recommendation,
  });

  final double zScore;
  final GrowthStatus status;
  final int ageMonths;

  /// Nilai apa adanya dari input.
  final double rawCm;

  /// Nilai setelah koreksi metode ukur (PB/TB).
  final double correctedCm;

  final MeasureMethod method;
  final MeasureMethod recommendedMethod;
  final bool methodAdjusted;
  final double weightKg;
  final DateTime measuredOn;
  final String refVersion;
  final Recommendation? recommendation;

  /// Nilai z dibulatkan untuk tampilan.
  String get zLabel => zScore.toStringAsFixed(2);

  bool get isImplausible => zScore < -6 || zScore > 6;
}
