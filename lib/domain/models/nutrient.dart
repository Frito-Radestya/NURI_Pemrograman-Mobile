/// Nutrien yang dipantau (PRD Bagian 3, OQ-7).
///
/// Enam pertama ditampilkan sebagai ring gizi harian; besi, seng, kalsium,
/// dan vitamin A ditampilkan pada detail.
enum Nutrient {
  energy('Energi', 'kkal', 'energy'),
  protein('Protein', 'g', 'protein'),
  fat('Lemak', 'g', 'fat'),
  carb('Karbohidrat', 'g', 'carb'),
  iron('Zat besi', 'mg', 'iron'),
  zinc('Zat seng', 'mg', 'zinc'),
  calcium('Kalsium', 'mg', 'calcium'),
  vitaminA('Vitamin A', 'mcg', 'vit_a');

  const Nutrient(this.label, this.unit, this.jsonKey);

  final String label;
  final String unit;

  /// Kunci pada aset TKPI / AKG.
  final String jsonKey;

  /// Nutrien yang tampil sebagai bar pada ringkasan harian.
  static const List<Nutrient> primary = <Nutrient>[
    energy,
    protein,
    fat,
    carb,
    iron,
    calcium,
  ];

  static Nutrient fromJsonKey(String key) {
    return Nutrient.values.firstWhere(
      (Nutrient n) => n.jsonKey == key,
      orElse: () => Nutrient.energy,
    );
  }
}

/// Ambang traffic light (PRD Bagian 3, OQ-7).
enum TrafficLight {
  kurang('Kurang'),
  cukup('Cukup'),
  lebih('Lebih');

  const TrafficLight(this.label);

  final String label;

  static TrafficLight fromPercent(double percent) {
    if (percent < 80) return TrafficLight.kurang;
    if (percent <= 120) return TrafficLight.cukup;
    return TrafficLight.lebih;
  }
}
