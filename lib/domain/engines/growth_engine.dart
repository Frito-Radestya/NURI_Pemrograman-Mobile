import '../models/child.dart';
import '../models/growth_result.dart';
import '../models/growth_status.dart';
import '../models/measurement.dart';
import '../models/recommendation.dart';
import '../models/sex.dart';
import '../models/who_lms.dart';
import 'age_calculator.dart';

/// Mesin pertumbuhan: prioritas #1, deterministik (PRD Bagian 2 & 6).
///
/// Murni Dart: tidak bergantung pada Flutter maupun Supabase agar bisa diuji.
class GrowthEngine {
  const GrowthEngine(this.table, {this.appVersion = '1.0.0'});

  final WhoLmsTable table;
  final String appVersion;

  /// Batas range panjang/tinggi badan fisiologis 0-59 bulan untuk validasi.
  static const double _minCm = 35;
  static const double _maxCm = 130;
  static const double _maxWeightKg = 40;

  /// Koreksi metode ukur PB/TB (PRD Bagian 6).
  static const double _methodCorrectionCm = 0.7;

  GrowthResult assess({
    required Child child,
    required DateTime measuredOn,
    required double weightKg,
    required double lengthHeightCm,
    required MeasureMethod method,
    RecommendationCatalog? recommendations,
  }) {
    if (measuredOn.isBefore(child.birthDate)) {
      throw const GrowthValidationException(
        GrowthValidationKind.tanggalTidakValid,
        'Tanggal ukur sebelum tanggal lahir anak.',
        hint: 'Periksa kembali tanggal lahir anak dan tanggal pengukuran.',
      );
    }

    final int ageMonths = AgeCalculator.inMonths(child.birthDate, measuredOn);
    final int ageDays = AgeCalculator.inDays(child.birthDate, measuredOn);
    if (!AgeCalculator.isScreenable(ageMonths)) {
      throw GrowthValidationException(
        GrowthValidationKind.umurDiLuarRentang,
        'Umur anak $ageMonths bulan. Skrining TB/U hanya untuk 0\u201359 bulan.',
        hint: 'Untuk umur di luar rentang ini, konsultasikan ke tenaga kesehatan.',
      );
    }

    if (lengthHeightCm < _minCm || lengthHeightCm > _maxCm) {
      throw GrowthValidationException(
        GrowthValidationKind.nilaiTidakMasukAkal,
        'Tinggi/panjang badan $lengthHeightCm cm tidak masuk akal untuk umur '
            '${AgeCalculator.label(ageMonths)}.',
        hint: 'Pastikan alat ukur benar dan anak berdiri/berbaring dengan tepat.',
      );
    }

    if (weightKg <= 0 || weightKg > _maxWeightKg) {
      throw const GrowthValidationException(
        GrowthValidationKind.nilaiTidakMasukAkal,
        'Berat badan di luar rentang yang masuk akal.',
        hint: 'Periksa kembali angka pada timbangan.',
      );
    }

    final MeasureMethod recommended = MeasureMethod.recommendedForDays(ageDays);
    double corrected = lengthHeightCm;
    bool adjusted = false;
    if (method == MeasureMethod.berbaring && recommended == MeasureMethod.berdiri) {
      corrected = lengthHeightCm - _methodCorrectionCm;
      adjusted = true;
    } else if (method == MeasureMethod.berdiri &&
        recommended == MeasureMethod.berbaring) {
      corrected = lengthHeightCm + _methodCorrectionCm;
      adjusted = true;
    }

    final LmsPoint point = table.atDays(child.sex, ageDays.toDouble());
    final double z = point.zScoreFor(corrected);

    // Plausibilitas: z < -6 atau z > +6 ditolak (PRD Bagian 6).
    if (z < -6 || z > 6) {
      throw GrowthValidationException(
        GrowthValidationKind.nilaiTidakMasukAkal,
        'Nilai z-score ${z.toStringAsFixed(2)} di luar batas yang masuk akal '
            '(\u22126 s.d. +6).',
        hint: 'Periksa kembali tinggi/panjang badan, tanggal lahir, dan jenis kelamin anak.',
      );
    }

    final GrowthStatus status = GrowthStatus.fromZ(z);
    final Recommendation? recommendation =
        recommendations?.find(status, ageMonths);

    return GrowthResult(
      zScore: z,
      status: status,
      ageMonths: ageMonths,
      rawCm: lengthHeightCm,
      correctedCm: corrected,
      method: method,
      recommendedMethod: recommended,
      methodAdjusted: adjusted,
      weightKg: weightKg,
      measuredOn: measuredOn,
      refVersion: table.refVersion,
      recommendation: recommendation,
    );
  }

  /// Nilai cm pada z tertentu, dipakai kurva pertumbuhan (F6).
  double valueAtZ({required Sex sex, required int month, required double z}) =>
      table.valueForZ(sex, month, z);
}
