import 'growth_status.dart';

/// Konten rekomendasi per status dan umur (F7, PRD Bagian 3 OQ-11).
class Recommendation {
  const Recommendation({
    required this.status,
    required this.ageBand,
    required this.title,
    required this.summary,
    required this.actions,
  });

  final GrowthStatus status;

  /// `under24` atau `over24`.
  final String ageBand;
  final String title;
  final String summary;
  final List<String> actions;

  static String bandFor(int ageMonths) =>
      ageMonths < 24 ? 'under24' : 'over24';
}

/// Katalog rekomendasi dari aset `recommendations.json`.
class RecommendationCatalog {
  const RecommendationCatalog({
    required this.refVersion,
    required this.items,
  });

  final String refVersion;
  final List<Recommendation> items;

  Recommendation? find(GrowthStatus status, int ageMonths) {
    final String band = Recommendation.bandFor(ageMonths);
    for (final Recommendation item in items) {
      if (item.status == status && item.ageBand == band) return item;
    }
    for (final Recommendation item in items) {
      if (item.status == status) return item;
    }
    return null;
  }
}
