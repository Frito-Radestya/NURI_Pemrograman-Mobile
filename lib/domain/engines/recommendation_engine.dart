import '../models/growth_result.dart';
import '../models/recommendation.dart';

/// Memilih rekomendasi sesuai status dan umur (F7).
class RecommendationEngine {
  const RecommendationEngine(this.catalog);

  final RecommendationCatalog catalog;

  Recommendation? forResult(GrowthResult result) =>
      catalog.find(result.status, result.ageMonths);
}
