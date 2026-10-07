import 'akg.dart';
import 'nutrient.dart';

/// Asupan satu nutrien dibandingkan target AKG.
class NutrientIntake {
  const NutrientIntake({
    required this.nutrient,
    required this.value,
    required this.target,
  });

  final Nutrient nutrient;
  final double value;
  final double target;

  bool get hasTarget => target > 0;

  double get percent => target <= 0 ? 0 : (value / target) * 100;

  TrafficLight get light => TrafficLight.fromPercent(percent);

  /// Selisih terhadap target (positif = lebih).
  double get delta => value - target;

  /// Kekurangan yang masih perlu dipenuhi.
  double get remaining => delta < 0 ? -delta : 0;
}

/// Ringkasan gizi harian anak (F11).
class NutritionSummary {
  const NutritionSummary({
    required this.group,
    required this.intakes,
    required this.loggedItems,
  });

  final AkgGroup group;
  final List<NutrientIntake> intakes;
  final int loggedItems;

  NutrientIntake intakeFor(Nutrient nutrient) {
    for (final NutrientIntake intake in intakes) {
      if (intake.nutrient == nutrient) return intake;
    }
    return NutrientIntake(nutrient: nutrient, value: 0, target: 0);
  }

  NutrientIntake get energy => intakeFor(Nutrient.energy);

  bool get isEmpty => loggedItems == 0;
}
