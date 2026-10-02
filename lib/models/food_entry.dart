// Model untuk satu item makanan di food diary.
// Field *_id menyimpan relasi ke user, katalog makanan, kategori, dan anak.
import '../data/akg_reference.dart';
class FoodEntry {
  final String id;
  final String userId;
  final String foodItemId;
  final String foodName;
  final String categoryId;
  final String? childId;
  final String dateKey; // YYYY-MM-DD
  final String session; // 'pagi', 'siang', 'malam', 'snack'
  final double portionGram;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime addedAt;
  final String? unit; // 'gram', 'porsi', 'butir', dll.

  const FoodEntry({
    required this.id,
    required this.userId,
    required this.foodItemId,
    required this.foodName,
    required this.categoryId,
    required this.dateKey,
    required this.session,
    required this.portionGram,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.addedAt,
    this.childId,
    this.unit,
  });

  FoodEntry copyWith({
    String? id,
    String? userId,
    String? foodItemId,
    String? foodName,
    String? categoryId,
    String? childId,
    bool clearChildId = false,
    String? dateKey,
    String? session,
    double? portionGram,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? addedAt,
    String? unit,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodItemId: foodItemId ?? this.foodItemId,
      foodName: foodName ?? this.foodName,
      categoryId: categoryId ?? this.categoryId,
      childId: clearChildId ? null : (childId ?? this.childId),
      dateKey: dateKey ?? this.dateKey,
      session: session ?? this.session,
      portionGram: portionGram ?? this.portionGram,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      addedAt: addedAt ?? this.addedAt,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'categoryId': categoryId,
      'childId': childId,
      'dateKey': dateKey,
      'session': session,
      'portionGram': portionGram,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'addedAt': addedAt.toIso8601String(),
      'unit': unit,
    };
  }

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? 'guest',
      foodItemId: map['foodItemId'] ?? '',
      foodName: map['foodName'] ?? '',
      categoryId: map['categoryId'] ?? '',
      childId: map['childId'],
      dateKey: map['dateKey'] ?? '',
      session: map['session'] ?? 'pagi',
      portionGram: (map['portionGram'] as num?)?.toDouble() ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      addedAt: DateTime.tryParse(map['addedAt'] ?? '') ?? DateTime.now(),
      unit: map['unit'],
    );
  }
}

// Ringkasan gizi total untuk satu hari
class DailyNutritionSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  // Target AKG harian (ibu balita / perempuan dewasa umum)
  static const double targetCalories = 2000;
  static const double targetProtein = 56; // gram
  static const double targetCarbs = 260; // gram
  static const double targetFat = 65; // gram

  const DailyNutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory DailyNutritionSummary.fromEntries(List<FoodEntry> entries) {
    double cal = 0, prot = 0, carb = 0, fat = 0;
    for (final e in entries) {
      cal += e.calories;
      prot += e.protein;
      carb += e.carbs;
      fat += e.fat;
    }
    return DailyNutritionSummary(
      totalCalories: cal,
      totalProtein: prot,
      totalCarbs: carb,
      totalFat: fat,
    );
  }

  double get caloriesPercent =>
      (totalCalories / targetCalories).clamp(0.0, 1.0);
  double get proteinPercent => (totalProtein / targetProtein).clamp(0.0, 1.0);
  double get carbsPercent => (totalCarbs / targetCarbs).clamp(0.0, 1.0);
  double get fatPercent => (totalFat / targetFat).clamp(0.0, 1.0);

  /// Ringkasan terhadap AKG anak (F-03.4). Mengembalikan persen 0-1 per nutrien.
  Map<String, double> percentOf(AkgTarget target) => {
        'calories': (totalCalories / target.calories).clamp(0.0, 2.0),
        'protein': (totalProtein / target.protein).clamp(0.0, 2.0),
        'carbs': (totalCarbs / target.carbs).clamp(0.0, 2.0),
        'fat': (totalFat / target.fat).clamp(0.0, 2.0),
      };

  /// Traffic light: 'kurang' | 'cukup' | 'lebih'
  String caloriesStatus() => _trafficLight(caloriesPercent);
  String proteinStatus() => _trafficLight(proteinPercent);
  String carbsStatus() => _trafficLight(carbsPercent);
  String fatStatus() => _trafficLight(fatPercent);

  String _trafficLight(double pct) {
    if (pct < 0.7) return 'kurang';
    if (pct <= 1.0) return 'cukup';
    return 'lebih';
  }
}
