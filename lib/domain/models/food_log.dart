import 'food_item.dart';
import 'nutrient.dart';

/// Sesi makan (PRD Bagian 8, `food_logs.meal`).
enum MealType {
  pagi('Pagi', '\u{1F305}'),
  siang('Siang', '\u2600\uFE0F'),
  malam('Malam', '\u{1F319}'),
  snack('Snack', '\u{1F34E}');

  const MealType(this.label, this.emoji);

  final String label;
  final String emoji;

  String get code => name;

  static MealType fromCode(String? code) => MealType.values.firstWhere(
    (MealType m) => m.name == code,
    orElse: () => MealType.pagi,
  );
}

/// Satu item makanan yang dicatat.
///
/// Secara model memetakan `food_logs` + `food_log_items` (PRD Bagian 8);
/// `meal` didenormalisasi agar mudah dipakai UI.
class FoodLogItem {
  const FoodLogItem({
    required this.id,
    required this.childId,
    required this.logDate,
    required this.meal,
    required this.tkpiId,
    required this.foodName,
    required this.emoji,
    required this.group,
    required this.portionLabel,
    required this.grams,
    required this.source,
    required this.nutrients,
    this.confidence,
    required this.createdAt,
  });

  final String id;
  final String childId;
  final DateTime logDate;
  final MealType meal;
  final String tkpiId;
  final String foodName;
  final String emoji;
  final String group;
  final String portionLabel;
  final double grams;
  final FoodSource source;
  final double? confidence;

  /// Nilai gizi terhitung untuk porsi ini.
  final Map<Nutrient, double> nutrients;
  final DateTime createdAt;

  double nutrient(Nutrient nutrient) => nutrients[nutrient] ?? 0;

  /// Nilai energi item ini.
  double get energy => nutrient(Nutrient.energy);
}
