import '../models/akg.dart';
import '../models/child.dart';
import '../models/food_log.dart';
import '../models/nutrient.dart';
import '../models/nutrition_summary.dart';

/// Mesin gizi: menjumlahkan asupan dan membandingkan dengan AKG (F11).
class NutritionEngine {
  const NutritionEngine(this.akg);

  final AkgCatalog akg;

  /// Ringkasan gizi untuk seorang anak pada tanggal tertentu.
  NutritionSummary summarize({
    required Child child,
    required DateTime date,
    required List<FoodLogItem> items,
  }) {
    final int ageMonths = child.ageInMonthsAt(date);
    final AkgGroup group =
        akg.groupFor(ageMonths: ageMonths, sex: child.sex);

    final Map<Nutrient, double> totals = <Nutrient, double>{
      for (final Nutrient nutrient in Nutrient.values) nutrient: 0,
    };

    for (final FoodLogItem item in items) {
      for (final Nutrient nutrient in Nutrient.values) {
        totals[nutrient] = (totals[nutrient] ?? 0) + item.nutrient(nutrient);
      }
    }

    final List<NutrientIntake> intakes = Nutrient.values
        .map(
          (Nutrient nutrient) => NutrientIntake(
            nutrient: nutrient,
            value: totals[nutrient] ?? 0,
            target: group.targetFor(nutrient),
          ),
        )
        .toList();

    return NutritionSummary(
      group: group,
      intakes: intakes,
      loggedItems: items.length,
    );
  }

  /// Total gizi sekelompok item (dipakai pratinjau sebelum simpan).
  Map<Nutrient, double> totalsOf(List<FoodLogItem> items) {
    final Map<Nutrient, double> totals = <Nutrient, double>{
      for (final Nutrient nutrient in Nutrient.values) nutrient: 0,
    };
    for (final FoodLogItem item in items) {
      for (final Nutrient nutrient in Nutrient.values) {
        totals[nutrient] = (totals[nutrient] ?? 0) + item.nutrient(nutrient);
      }
    }
    return totals;
  }
}
