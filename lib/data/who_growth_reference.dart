// Referensi WHO Child Growth Standards (ringkas, untuk demo).
//
// PENTING: angka di bawah adalah ANCHOR DEMO yang mendekati median WHO
// untuk keperluan alur UI + unit test. Sebelum dipakai penilaian klinis,
// ganti dengan tabel LMS resmi WHO (L, M, S per bulan 0-60, Laki/Prmp,
// PB 0-24 bln & TB 24-60 bln) dari file CSV resmi dan verifikasi
// selisih z-score vs kalkulator WHO (PRD §9, OQ-14).
//
// Rumus LMS (L=1 untuk TB/U & PB/U):
//   z = ((y / M) - 1) / S
class WhoAnchor {
  final int month;
  final double median;
  final double s;
  const WhoAnchor(this.month, this.median, this.s);
}

class WhoGrowthReference {
  static const double l = 1.0;

  // Median tinggi/panjang (cm). Sumber anchor: publikasi WHO median
  // dibulatkan; S tipikal 0.037-0.044 untuk TB/U.
  static const List<WhoAnchor> boys = [
    WhoAnchor(0, 49.9, 0.038),
    WhoAnchor(6, 67.6, 0.038),
    WhoAnchor(12, 75.7, 0.039),
    WhoAnchor(18, 82.3, 0.040),
    WhoAnchor(24, 87.1, 0.040),
    WhoAnchor(36, 96.1, 0.041),
    WhoAnchor(48, 103.3, 0.042),
    WhoAnchor(60, 110.0, 0.043),
  ];

  static const List<WhoAnchor> girls = [
    WhoAnchor(0, 49.1, 0.038),
    WhoAnchor(6, 65.7, 0.039),
    WhoAnchor(12, 74.0, 0.040),
    WhoAnchor(18, 80.7, 0.040),
    WhoAnchor(24, 85.7, 0.041),
    WhoAnchor(36, 95.1, 0.042),
    WhoAnchor(48, 102.7, 0.043),
    WhoAnchor(60, 109.4, 0.044),
  ];

  /// Interpolasi linear median & S untuk [month] 0-60.
  static ({double median, double s}) lmsFor({
    required int month,
    required bool isBoy,
  }) {
    final table = isBoy ? boys : girls;
    final m = month.clamp(0, 60);
    for (var i = 0; i < table.length - 1; i++) {
      final a = table[i];
      final b = table[i + 1];
      if (m >= a.month && m <= b.month) {
        final t = (m - a.month) / (b.month - a.month);
        return (
          median: a.median + (b.median - a.median) * t,
          s: a.s + (b.s - a.s) * t,
        );
      }
    }
    final last = table.last;
    return (median: last.median, s: last.s);
  }
}
