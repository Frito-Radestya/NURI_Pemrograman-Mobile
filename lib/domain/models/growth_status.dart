/// Klasifikasi TB/U atau PB/U (PRD Bagian 6).
enum GrowthStatus {
  sangatPendek('Sangat pendek', 'sangat_pendek', 'Anak sangat pendek'),
  pendek('Pendek', 'pendek', 'Lebih pendek dari anak seumurnya'),
  normal('Normal', 'normal', 'Tinggi badan sesuai usia'),
  tinggi('Tinggi', 'tinggi', 'Tinggi badan di atas rata-rata');

  const GrowthStatus(this.label, this.code, this.plainLanguage);

  final String label;

  /// Kode yang dipakai pada aset / basis data.
  final String code;

  /// Kalimat sederhana untuk pengguna (PRD: mikrocopy).
  final String plainLanguage;

  /// Klasifikasi dari nilai z (PRD Bagian 6).
  static GrowthStatus fromZ(double z) {
    if (z < -3) return GrowthStatus.sangatPendek;
    if (z < -2) return GrowthStatus.pendek;
    if (z <= 3) return GrowthStatus.normal;
    return GrowthStatus.tinggi;
  }

  static GrowthStatus fromCode(String? code) {
    return GrowthStatus.values.firstWhere(
      (GrowthStatus s) => s.code == code,
      orElse: () => GrowthStatus.normal,
    );
  }

  bool get needsFollowUp =>
      this == GrowthStatus.pendek || this == GrowthStatus.sangatPendek;
}
