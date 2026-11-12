import 'dart:convert';

import '../models.dart';

class FoodCatalogItem {
  const FoodCatalogItem({
    required this.id,
    required this.name,
    required this.originalName,
    required this.category,
    required this.source,
    this.energyKcal,
    this.proteinG,
    this.fatG,
    this.carbG,
    this.fiberG,
    this.ironMg,
    this.zincMg,
    this.calciumMg,
    this.vitaminAMcg,
    this.vitaminCMg,
  });

  final String id;
  final String name;
  final String originalName;
  final String category;
  final String source;
  final double? energyKcal;
  final double? proteinG;
  final double? fatG;
  final double? carbG;
  final double? fiberG;
  final double? ironMg;
  final double? zincMg;
  final double? calciumMg;
  final double? vitaminAMcg;
  final double? vitaminCMg;

  FoodLogItem toLogItem({
    required double grams,
    FoodSource foodSource = FoodSource.manual,
    double? confidence,
  }) => FoodLogItem(
    foodId: id,
    name: name,
    grams: grams,
    kcalPer100: energyKcal,
    proteinPer100: proteinG,
    fatPer100: fatG,
    carbPer100: carbG,
    ironPer100: ironMg,
    zincPer100: zincMg,
    source: foodSource,
    confidence: confidence,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'originalName': originalName,
    'category': category,
    'source': source,
    'energyKcal': energyKcal,
    'proteinG': proteinG,
    'fatG': fatG,
    'carbG': carbG,
    'fiberG': fiberG,
    'ironMg': ironMg,
    'zincMg': zincMg,
    'calciumMg': calciumMg,
    'vitaminAMcg': vitaminAMcg,
    'vitaminCMg': vitaminCMg,
  };

  factory FoodCatalogItem.fromJson(Map<String, dynamic> json) =>
      FoodCatalogItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        originalName: json['originalName'] as String? ?? '',
        category: json['category'] as String? ?? 'Lainnya',
        source: json['source'] as String? ?? 'TKPI 2017',
        energyKcal: parseDouble(json['energyKcal']),
        proteinG: parseDouble(json['proteinG']),
        fatG: parseDouble(json['fatG']),
        carbG: parseDouble(json['carbG']),
        fiberG: parseDouble(json['fiberG']),
        ironMg: parseDouble(json['ironMg']),
        zincMg: parseDouble(json['zincMg']),
        calciumMg: parseDouble(json['calciumMg']),
        vitaminAMcg: parseDouble(json['vitaminAMcg']),
        vitaminCMg: parseDouble(json['vitaminCMg']),
      );
}

class FoodCatalog {
  const FoodCatalog({required this.version, required this.foods});

  final String version;
  final List<FoodCatalogItem> foods;

  static FoodCatalog? _instance;
  static FoodCatalog get instance {
    final value = _instance;
    if (value == null) {
      throw StateError('FoodCatalog belum dimuat.');
    }
    return value;
  }

  static bool get isLoaded => _instance != null;
  static void setInstance(FoodCatalog catalog) => _instance = catalog;

  static FoodCatalog fromJsonString(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return FoodCatalog(
      version: json['version'] as String? ?? 'tkpi-v1',
      foods: (json['foods'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => FoodCatalogItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  FoodCatalogItem? byId(String id) {
    for (final item in foods) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<FoodCatalogItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return foods;
    return foods
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.originalName.toLowerCase().contains(q) ||
              f.category.toLowerCase().contains(q),
        )
        .toList();
  }

  List<String> get categories {
    final set = foods.map((e) => e.category).toSet().toList()..sort();
    return set;
  }
}
