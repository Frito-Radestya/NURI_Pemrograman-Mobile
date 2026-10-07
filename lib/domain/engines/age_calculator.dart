/// Perhitungan umur (PRD Bagian 6).
///
/// Umur dihitung dari tanggal lahir ke tanggal ukur, dalam bulan penuh.
class AgeCalculator {
  AgeCalculator._();

  static const int maxScreeningMonths = 59;

  /// Umur dalam bulan penuh. Tidak pernah negatif.
  static int inMonths(DateTime birthDate, DateTime at) {
    int months = (at.year - birthDate.year) * 12 + (at.month - birthDate.month);
    if (at.day < birthDate.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  static int inDays(DateTime birthDate, DateTime at) {
    final int days = at.difference(birthDate).inDays;
    return days < 0 ? 0 : days;
  }

  static double inYears(DateTime birthDate, DateTime at) =>
      inDays(birthDate, at) / 365.25;

  /// Label umur sederhana untuk pengguna.
  static String label(int months) {
    if (months <= 0) {
      return '< 1 bulan';
    }
    if (months < 12) {
      return '$months bulan';
    }
    final int years = months ~/ 12;
    final int rest = months % 12;
    if (rest == 0) {
      return '$years tahun';
    }
    return '$years tahun $rest bulan';
  }

  /// Umur pada saat ukur, dipakai menyimpan `age_months`.
  static bool isScreenable(int months) =>
      months >= 0 && months <= maxScreeningMonths;
}
