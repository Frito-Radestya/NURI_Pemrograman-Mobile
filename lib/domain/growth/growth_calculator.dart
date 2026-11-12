import 'dart:math' as math;

import '../models.dart';
import 'who_lms.dart';

class GrowthEvaluation {
  const GrowthEvaluation({
    required this.ageDays,
    required this.ageMonths,
    required this.zScore,
    required this.category,
    required this.measuredCm,
    required this.correctedCm,
    required this.method,
    required this.medianCm,
    required this.minus3Cm,
    required this.minus2Cm,
    required this.plus2Cm,
    required this.plus3Cm,
    required this.flags,
    required this.implausible,
    this.correctionNote,
  });

  final int ageDays;
  final int ageMonths;
  final double zScore;
  final GrowthCategory category;
  final double measuredCm;
  final double correctedCm;
  final MeasurementMethod method;
  final double medianCm;
  final double minus3Cm;
  final double minus2Cm;
  final double plus2Cm;
  final double plus3Cm;
  final List<String> flags;
  final bool implausible;
  final String? correctionNote;

  bool get isBelowMinus2 => zScore < -2;
  bool get isBelowMinus3 => zScore < -3;
}

class GrowthValidationException implements Exception {
  GrowthValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Mesin skrining pertumbuhan. Murni, deterministik, tanpa Firebase/UI.
class GrowthCalculator {
  const GrowthCalculator({required this.reference});

  final WhoReference reference;

  static const double minLengthCm = 35;
  static const double maxLengthCm = 130;
  static const double minWeightKg = 1.5;
  static const double maxWeightKg = 30;
  static const double correctionCm = 0.7;

  GrowthEvaluation evaluate({
    required double heightCm,
    required double weightKg,
    required Sex sex,
    required DateTime dob,
    required DateTime measureDate,
    required MeasurementMethod method,
    bool allowImplausible = false,
  }) {
    if (heightCm < minLengthCm || heightCm > maxLengthCm) {
      throw GrowthValidationException(
        'Panjang/tinggi ${heightCm.toStringAsFixed(1)} cm di luar rentang yang wajar '
        '(${minLengthCm.toStringAsFixed(0)}–${maxLengthCm.toStringAsFixed(0)} cm). Periksa kembali.',
      );
    }
    if (weightKg < minWeightKg || weightKg > maxWeightKg) {
      throw GrowthValidationException(
        'Berat ${weightKg.toStringAsFixed(1)} kg di luar rentang yang wajar '
        '(${minWeightKg.toStringAsFixed(1)}–${maxWeightKg.toStringAsFixed(0)} kg). Periksa kembali.',
      );
    }
    final ageDays = dateOnly(measureDate).difference(dateOnly(dob)).inDays;
    if (ageDays < 0) {
      throw GrowthValidationException(
        'Tanggal ukur tidak boleh sebelum tanggal lahir.',
      );
    }
    if (ageDays > 1856) {
      throw GrowthValidationException(
        'Usia ${(ageDays / 30.4375).floor()} bulan di luar cakupan skrining 0–59 bulan.',
      );
    }

    final ageMonths = (ageDays / 30.4375).floor();
    var corrected = heightCm;
    String? note;
    final flags = <String>[];

    if (ageMonths < 24 && method == MeasurementMethod.standing) {
      corrected = heightCm + correctionCm;
      note = 'Diukur berdiri pada usia < 24 bulan. Panjang badan dikoreksi +0,7 cm.';
      flags.add('Koreksi PB +0,7 cm');
    } else if (ageMonths >= 24 && method == MeasurementMethod.lying) {
      corrected = heightCm - correctionCm;
      note = 'Diukur berbaring pada usia ≥ 24 bulan. Tinggi badan dikoreksi −0,7 cm.';
      flags.add('Koreksi TB −0,7 cm');
    }

    final table = reference.forSex(sex);
    final point = table.atAgeDays(ageDays.toDouble());
    final z = _zScore(corrected, point);
    final category = classify(z);
    var implausible = false;
    if (z.abs() > 6) {
      implausible = true;
      flags.add('Nilai z di luar ±6; periksa kembali input');
    }
    if (!allowImplausible && implausible) {
      throw GrowthValidationException(
        'Hasil z-score ${z.toStringAsFixed(2)} SD sangat tidak biasa. '
        'Periksa kembali tinggi/panjang dan tanggal lahir sebelum menyimpan.',
      );
    }

    return GrowthEvaluation(
      ageDays: ageDays,
      ageMonths: ageMonths,
      zScore: z,
      category: category,
      measuredCm: heightCm,
      correctedCm: corrected,
      method: method,
      medianCm: point.m,
      minus3Cm: table.valueAtZ(ageDays.toDouble(), -3),
      minus2Cm: table.valueAtZ(ageDays.toDouble(), -2),
      plus2Cm: table.valueAtZ(ageDays.toDouble(), 2),
      plus3Cm: table.valueAtZ(ageDays.toDouble(), 3),
      flags: flags,
      implausible: implausible,
      correctionNote: note,
    );
  }

  static double _zScore(double value, LmsPoint point) {
    if (point.s.abs() < 1e-12 || point.m <= 0 || value <= 0) return 0;
    if (point.l.abs() < 1e-9) {
      return math.log(value / point.m) / point.s;
    }
    final powered = math.pow(value / point.m, point.l).toDouble();
    return (powered - 1) / (point.l * point.s);
  }

  static GrowthCategory classify(double z) {
    if (z < -3) return GrowthCategory.severelyStunted;
    if (z < -2) return GrowthCategory.stunted;
    if (z <= 3) return GrowthCategory.normal;
    return GrowthCategory.tall;
  }

  /// Nilai referensi untuk chart pada umur tertentu.
  List<double> chartValues({required Sex sex, required int ageDays}) {
    final table = reference.forSex(sex);
    final age = ageDays.toDouble();
    return [
      table.valueAtZ(age, -3),
      table.valueAtZ(age, -2),
      table.valueAtZ(age, 0),
      table.valueAtZ(age, 2),
      table.valueAtZ(age, 3),
    ];
  }

  /// Default metode ukur mengikuti umur (PRD §8.2).
  static MeasurementMethod defaultMethodForAge(int ageMonths) =>
      ageMonths < 24 ? MeasurementMethod.lying : MeasurementMethod.standing;
}
