import '../data/who_growth_reference.dart';

/// Hasil skrining z-score WHO (F-05). Penentu utama, tidak diubah foto.
class ScreeningResult {
  final int ageMonths;
  final bool isLength; // true = PB (<24 bln), false = TB
  final double measuredCm;
  final double correctedCm;
  final bool correctionApplied;
  final double zScore;
  final String category; // Sangat Pendek | Pendek | Normal | Tinggi
  final String recommendation;

  const ScreeningResult({
    required this.ageMonths,
    required this.isLength,
    required this.measuredCm,
    required this.correctedCm,
    required this.correctionApplied,
    required this.zScore,
    required this.category,
    required this.recommendation,
  });
}

/// Hitung umur bulan + z-score LMS + klasifikasi (PRD F-04/F-05/F-06).
class WhoService {
  /// Umur bulan penuh (tolak tanggal lahir di masa depan).
  static int ageMonths(DateTime birth, DateTime measure) {
    if (measure.isBefore(birth)) {
      throw ArgumentError('Tanggal ukur sebelum tanggal lahir.');
    }
    var months =
        (measure.year - birth.year) * 12 + measure.month - birth.month;
    if (measure.day < birth.day) months--;
    return months;
  }

  /// Aturan WHO: <24 bln berbaring (PB), >=24 bln berdiri (TB).
  /// Koreksi bila metode tidak sesuai umur: PB->TB -0.7cm, TB->PB +0.7cm.
  static ({bool isLength, double correctedCm, bool applied}) resolveMethod({
    required int ageMonths,
    required double measuredCm,
    required bool measuredIsLength,
  }) {
    final shouldBeLength = ageMonths < 24;
    if (measuredIsLength == shouldBeLength) {
      return (isLength: shouldBeLength, correctedCm: measuredCm, applied: false);
    }
    final corrected = measuredIsLength ? measuredCm - 0.7 : measuredCm + 0.7;
    return (isLength: shouldBeLength, correctedCm: corrected, applied: true);
  }

  static void validate({
    required int ageMonths,
    required double weightKg,
    required double heightCm,
  }) {
    if (ageMonths < 0 || ageMonths > 59) {
      throw ArgumentError('Usia harus 0-59 bulan untuk skrining.');
    }
    if (weightKg < 1 || weightKg > 40) {
      throw ArgumentError('Berat 1-40 kg.');
    }
    if (heightCm < 30 || heightCm > 130) {
      throw ArgumentError('Tinggi 30-130 cm.');
    }
  }

  static double zScore({
    required double heightCm,
    required int ageMonths,
    required bool isBoy,
  }) {
    final lms = WhoGrowthReference.lmsFor(month: ageMonths, isBoy: isBoy);
    return ((heightCm / lms.median) - 1) / lms.s;
  }

  /// F-05.2: < -3 sangat pendek; -3 s.d. < -2 pendek; -2 s.d. +3 normal.
  static String classify(double z) {
    if (z < -3) return 'Sangat Pendek';
    if (z < -2) return 'Pendek';
    if (z <= 3) return 'Normal';
    return 'Tinggi';
  }

  /// Bank konten statis (F-06). Konten sangat-pendek & >=24 bln minimal,
  /// wajib ditelaah ahli gizi sebelum rilis (OQ-11).
  static String recommendation(String category, int ageMonths) {
    switch (category) {
      case 'Sangat Pendek':
        return 'SEGERA ke Puskesmas/posyandu. Lanjutkan MPASI tinggi protein '
            '(telur, ikan, tempe, ayam) + ASI bila <24 bln. Jangan tunda.';
      case 'Pendek':
        return 'MPASI tinggi protein + jadwal kontrol ke Puskesmas/posyandu. '
            'Pantau tiap bulan dengan kurva WHO.';
      case 'Tinggi':
        return 'Tinggi di atas +3SD. Konsultasikan ke tenaga kesehatan '
            'untuk evaluasi.';
      default:
        return ageMonths < 6
            ? 'ASI eksklusif + pantau BB/TB bulanan.'
            : 'Pertahankan menu seimbang + pantau kurva WHO tiap bulan.';
    }
  }

  static ScreeningResult screen({
    required DateTime birthDate,
    required DateTime measureDate,
    required bool isBoy,
    required double weightKg,
    required double measuredCm,
    required bool measuredIsLength,
  }) {
    final age = ageMonths(birthDate, measureDate);
    validate(ageMonths: age, weightKg: weightKg, heightCm: measuredCm);
    final method = resolveMethod(
      ageMonths: age,
      measuredCm: measuredCm,
      measuredIsLength: measuredIsLength,
    );
    final z = zScore(
      heightCm: method.correctedCm,
      ageMonths: age,
      isBoy: isBoy,
    );
    final cat = classify(z);
    return ScreeningResult(
      ageMonths: age,
      isLength: method.isLength,
      measuredCm: measuredCm,
      correctedCm: method.correctedCm,
      correctionApplied: method.applied,
      zScore: z,
      category: cat,
      recommendation: recommendation(cat, age),
    );
  }
}

/// Indikator tambahan dari foto (eksperimental, BUKAN penentu).
///
/// Fakta: tidak ada model pretrained publik yang valid untuk
/// "stunting dari proporsi tubuh foto". Implementasi produksi yang benar:
/// MoveNet Lightning (pretrained pose, ±12MB TFLite) -> keypoints ->
/// rasio tubuh -> tampilkan berdampingan dengan label eksperimental.
/// Saat ini: stub quality-gate + slot injeksi model.
class PhotoIndicatorService {
  static const String experimentalLabel =
      'Indikator tambahan (eksperimental) — penentu tetap z-score';

  /// Stub cek kualitas (F-05.7). Produksi: 1 orang, full-body,
  /// tidak buram, cahaya cukup via ML Kit / blur detection.
  static ({bool passed, String message}) qualityGate({required bool hasImage}) {
    if (!hasImage) return (passed: false, message: 'Belum ada foto.');
    return (passed: true, message: 'Foto lolos cek dasar (stub).');
  }
}
