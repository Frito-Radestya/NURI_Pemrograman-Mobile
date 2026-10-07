import 'nutrient.dart';

/// Ukuran rumah tangga dengan preset gram (PRD Bagian 3, OQ-4).
class FoodPortion {
  const FoodPortion({required this.label, required this.grams});

  final String label;
  final double grams;
}

/// Sumber entri makanan.
enum FoodSource {
  scan('Scan'),
  manual('Cari manual');

  const FoodSource(this.label);

  final String label;

  String get code => name;

  static FoodSource fromCode(String? code) => FoodSource.values.firstWhere(
    (FoodSource s) => s.name == code,
    orElse: () => FoodSource.manual,
  );
}

/// Satu makanan pada katalog TKPI.
class TkpiFood {
  const TkpiFood({
    required this.id,
    required this.name,
    required this.emoji,
    required this.group,
    required this.per100g,
    required this.portions,
  });

  final String id;
  final String name;
  final String emoji;
  final String group;

  /// Kandungan gizi per 100 gram.
  final Map<Nutrient, double> per100g;
  final List<FoodPortion> portions;

  FoodPortion get defaultPortion =>
      portions.isEmpty ? const FoodPortion(label: '100 g', grams: 100) : portions.first;

  /// Nilai gizi = gram / 100 x nilai per 100 g (PRD Bagian 7 langkah 4).
  Map<Nutrient, double> nutrientsFor(double grams) {
    final double factor = grams / 100.0;
    return <Nutrient, double>{
      for (final MapEntry<Nutrient, double> e in per100g.entries)
        e.key: e.value * factor,
    };
  }

  /// Apakah nilai TKPI tersedia. Bila tidak, item tidak dihitung sebagai nol.
  bool get hasNutritionData =>
      per100g.values.any((double value) => value > 0);
}

/// Kandidat hasil klasifikasi model makanan (top-3).
class FoodCandidate {
  const FoodCandidate({required this.food, required this.confidence});

  final TkpiFood food;

  /// Skor 0..1.
  final double confidence;

  /// Ambang kepercayaan 0,60 (PRD Bagian 3, OQ-6).
  static const double threshold = 0.60;

  bool get isConfident => confidence >= threshold;
}

/// Katalog TKPI dari aset `tkpi.json`.
class TkpiCatalog {
  const TkpiCatalog({required this.refVersion, required this.foods});

  final String refVersion;
  final List<TkpiFood> foods;

  TkpiFood? byId(String id) {
    for (final TkpiFood food in foods) {
      if (food.id == id) return food;
    }
    return null;
  }

  /// Daftar kelompok unik untuk filter.
  List<String> get groups {
    final List<String> result = <String>[];
    for (final TkpiFood food in foods) {
      if (!result.contains(food.group)) result.add(food.group);
    }
    return result;
  }

  /// Pencarian lokal < 300 ms (F10): cocokkan nama dan kelompok.
  List<TkpiFood> search(String query, {int limit = 30}) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return foods.take(limit).toList();
    final List<TkpiFood> startsWith = <TkpiFood>[];
    final List<TkpiFood> contains = <TkpiFood>[];
    for (final TkpiFood food in foods) {
      final String name = food.name.toLowerCase();
      if (name.startsWith(q)) {
        startsWith.add(food);
      } else if (name.contains(q) || food.group.toLowerCase().contains(q)) {
        contains.add(food);
      }
    }
    return <TkpiFood>[...startsWith, ...contains].take(limit).toList();
  }
}
