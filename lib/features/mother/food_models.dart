import '../../domain/models.dart';
import '../../domain/nutrition/food_catalog.dart';

class DetectedFood {
  DetectedFood({
    required this.food,
    required this.displayName,
    required this.grams,
    required this.confidence,
    this.selected = true,
  });

  final FoodCatalogItem food;
  final String displayName;
  final double grams;
  final double confidence;
  final bool selected;

  FoodLogItem toLogItem() => food.toLogItem(
    grams: grams,
    foodSource: FoodSource.ai,
    confidence: confidence,
  );

  DetectedFood copyWith({double? grams, bool? selected}) => DetectedFood(
    food: food,
    displayName: displayName,
    grams: grams ?? this.grams,
    confidence: confidence,
    selected: selected ?? this.selected,
  );
}
