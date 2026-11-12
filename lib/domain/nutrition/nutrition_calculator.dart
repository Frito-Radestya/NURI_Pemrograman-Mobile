import '../models.dart';

class AkgTarget {
  const AkgTarget({
    required this.label,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
    required this.ironMg,
    required this.zincMg,
  });

  final String label;
  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbG;
  final double ironMg;
  final double zincMg;

  double targetFor(String nutrient) => switch (nutrient) {
    'energi' => energyKcal,
    'protein' => proteinG,
    'lemak' => fatG,
    'karbohidrat' => carbG,
    'zat besi' => ironMg,
    'zink' => zincMg,
    _ => energyKcal,
  };
}

enum NutrientStatus {
  low('Kurang', 'Perlu ditambah'),
  adequate('Cukup', 'Sesuai anjuran'),
  high('Lebih', 'Perhatikan porsi');

  const NutrientStatus(this.label, this.hint);
  final String label;
  final String hint;

  static NutrientStatus fromPercent(double percent) {
    if (percent < 80) return NutrientStatus.low;
    if (percent <= 110) return NutrientStatus.adequate;
    return NutrientStatus.high;
  }
}

/// Referensi AKG Kemenkes 2019. Nilai gizi dibulatkan untuk tampilan,
/// bukan pengganti penilaian ahli gizi (OQ-7).
class AkgReference {
  const AkgReference();

  static const String sourceLabel = 'AKG Kemenkes 2019 • OQ-7';

  AkgTarget forChild(int ageMonths, Sex sex) {
    if (ageMonths < 6) {
      return const AkgTarget(
        label: '0–5 bulan',
        energyKcal: 550,
        proteinG: 9,
        fatG: 31,
        carbG: 58,
        ironMg: 0.3,
        zincMg: 1.1,
      );
    }
    if (ageMonths < 12) {
      return const AkgTarget(
        label: '6–11 bulan',
        energyKcal: 800,
        proteinG: 15,
        fatG: 35,
        carbG: 105,
        ironMg: 11,
        zincMg: 3,
      );
    }
    if (ageMonths < 36) {
      return const AkgTarget(
        label: '1–3 tahun',
        energyKcal: 1350,
        proteinG: 20,
        fatG: 45,
        carbG: 215,
        ironMg: 7,
        zincMg: 3,
      );
    }
    return AkgTarget(
      label: '4–6 tahun',
      energyKcal: 1400,
      proteinG: 25,
      fatG: 50,
      carbG: 220,
      ironMg: 10,
      zincMg: 5,
    );
  }

  AkgTarget forPregnancy(int trimester) => switch (trimester) {
    1 => const AkgTarget(
      label: 'Ibu hamil trimester 1',
      energyKcal: 2250,
      proteinG: 60,
      fatG: 65,
      carbG: 360,
      ironMg: 18,
      zincMg: 11,
    ),
    2 => const AkgTarget(
      label: 'Ibu hamil trimester 2',
      energyKcal: 2550,
      proteinG: 70,
      fatG: 75,
      carbG: 400,
      ironMg: 18,
      zincMg: 11,
    ),
    _ => const AkgTarget(
      label: 'Ibu hamil trimester 3',
      energyKcal: 2550,
      proteinG: 85,
      fatG: 75,
      carbG: 400,
      ironMg: 18,
      zincMg: 11,
    ),
  };

  /// Target protein hewani harian yang dipakai pada panduan MPASI.
  double animalProteinTargetFor(int ageMonths) => ageMonths < 24 ? 15 : 20;

  /// Target tablet tambah darah selama kehamilan (PRD F-04.5).
  static const int ttdTarget = 90;
  static const int ancTarget = 6;
}

class NutritionCalculator {
  const NutritionCalculator();

  static double? percent(double? value, double target) {
    if (value == null || target <= 0) return null;
    return value / target * 100;
  }

  static NutrientStatus? status(double? value, double target) {
    final p = percent(value, target);
    return p == null ? null : NutrientStatus.fromPercent(p);
  }

  /// Status protein hewani memakai target gram, bukan AKG total.
  static NutrientStatus animalProteinStatus(double? grams, double target) {
    final p = percent(grams, target) ?? 0;
    if (p < 80) return NutrientStatus.low;
    if (p <= 110) return NutrientStatus.adequate;
    return NutrientStatus.high;
  }

  /// Batas indikator pemenuhan, contoh awal PRD §8.7.
  static String indicatorLabel(NutrientStatus status) => status.label;
}
