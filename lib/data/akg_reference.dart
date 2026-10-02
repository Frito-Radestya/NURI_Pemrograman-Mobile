// AKG anak 0-60 bulan (ringkas, demo) + dewasa fallback.
//
// PENTING: angka contoh mendekati AKG Kemenkes 2019 untuk alur UI.
// Sebelum rilis: ganti dengan tabel AKG resmi per kelompok umur/jk
// dan kunci ambang traffic-light (OQ-7) bersama ahli gizi.
class AkgTarget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  const AkgTarget({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class AkgReference {
  /// AKG by umur bulan (disederhanakan dari kelompok AKG balita).
  static AkgTarget forChild({required int ageMonths, required bool isBoy}) {
    if (ageMonths < 6) {
      return const AkgTarget(
        calories: 550,
        protein: 9,
        carbs: 60,
        fat: 30,
      );
    }
    if (ageMonths < 12) {
      return const AkgTarget(
        calories: 800,
        protein: 15,
        carbs: 105,
        fat: 30,
      );
    }
    if (ageMonths < 36) {
      return const AkgTarget(
        calories: 1350,
        protein: 20,
        carbs: 175,
        fat: 45,
      );
    }
    return const AkgTarget(
      calories: 1400,
      protein: 25,
      carbs: 190,
      fat: 50,
    );
  }

  static const adult = AkgTarget(
    calories: 2000,
    protein: 56,
    carbs: 260,
    fat: 65,
  );
}
