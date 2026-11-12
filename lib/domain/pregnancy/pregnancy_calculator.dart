import '../models.dart';

class PregnancyProgress {
  const PregnancyProgress({
    required this.weeks,
    required this.days,
    required this.trimester,
    required this.daysToHpl,
    required this.progress,
    required this.fetalLengthCm,
    required this.fetalWeightG,
    required this.sizeLabel,
  });

  final int weeks;
  final int days;
  final int trimester;
  final int daysToHpl;
  final double progress;
  final double fetalLengthCm;
  final int fetalWeightG;
  final String sizeLabel;

  String get ageLabel => '$weeks minggu $days hari';
  int get totalWeeks => weeks;
}

class PregnancyCalculator {
  const PregnancyCalculator();

  static DateTime hplFromHpht(DateTime hpht) =>
      dateOnly(hpht).add(const Duration(days: 280));

  static DateTime hphtFromHpl(DateTime hpl) =>
      dateOnly(hpl).subtract(const Duration(days: 280));

  static int gestationalDays(DateTime hpht, DateTime today) =>
      dateOnly(today).difference(dateOnly(hpht)).inDays;

  static int trimesterForWeeks(int weeks) {
    if (weeks <= 13) return 1;
    if (weeks <= 27) return 2;
    return 3;
  }

  static PregnancyProgress progress({
    required DateTime hpht,
    required DateTime hpl,
    DateTime? today,
  }) {
    final now = dateOnly(today ?? DateTime.now());
    final days = gestationalDays(hpht, now);
    final safeDays = days < 0 ? 0 : days;
    final weeks = safeDays ~/ 7;
    final remainder = safeDays % 7;
    final totalDays = 280.0;
    final progress = (safeDays / totalDays).clamp(0.0, 1.0).toDouble();
    final fetal = _fetalForWeek(weeks);
    return PregnancyProgress(
      weeks: weeks,
      days: remainder,
      trimester: trimesterForWeeks(weeks),
      daysToHpl: dateOnly(hpl).difference(now).inDays,
      progress: progress,
      fetalLengthCm: fetal.$1,
      fetalWeightG: fetal.$2,
      sizeLabel: fetal.$3,
    );
  }

  static (double, int, String) _fetalForWeek(int weeks) {
    const sizes = <int, (double, int, String)>{
      4: (0.2, 1, 'sebesar biji poppy'),
      6: (0.6, 2, 'sebesar kacang polong'),
      8: (1.6, 2, 'sebesar raspberry'),
      10: (3.1, 4, 'sebesar stroberi'),
      12: (5.4, 14, 'sebesar jeruk nipis'),
      14: (8.7, 43, 'sebesar lemon'),
      16: (11.6, 100, 'sebesar alpukat'),
      18: (14.2, 190, 'sebesar paprika'),
      20: (25.6, 300, 'sebesar pisang'),
      22: (27.8, 430, 'sebesar pepaya kecil'),
      24: (30.0, 600, 'sebesar pepaya kecil'),
      26: (35.6, 760, 'sebesar wortel besar'),
      28: (37.6, 1000, 'sebesar terong'),
      30: (39.9, 1300, 'sebesar kubis'),
      32: (42.4, 1700, 'sebesar labu kecil'),
      34: (45.0, 2100, 'sebesar nanas'),
      36: (47.4, 2600, 'sebesar selada besar'),
      38: (49.0, 3000, 'sebesar semangka kecil'),
      40: (51.2, 3400, 'sebesar semangka kecil'),
    };
    if (sizes.containsKey(weeks)) return sizes[weeks]!;
    final keys = sizes.keys.toList()..sort();
    if (weeks <= keys.first) return sizes[keys.first]!;
    if (weeks >= keys.last) return sizes[keys.last]!;
    var lower = keys.first;
    for (final k in keys) {
      if (k <= weeks) lower = k;
    }
    final upper = keys.firstWhere((k) => k >= weeks, orElse: () => lower);
    if (upper == lower) return sizes[lower]!;
    final t = (weeks - lower) / (upper - lower);
    final a = sizes[lower]!;
    final b = sizes[upper]!;
    return (
      a.$1 + (b.$1 - a.$1) * t,
      (a.$2 + (b.$2 - a.$2) * t).round(),
      t < 0.5 ? a.$3 : b.$3,
    );
  }

  static String trimesterLabel(int trimester) => switch (trimester) {
    1 => 'Trimester 1',
    2 => 'Trimester 2',
    _ => 'Trimester 3',
  };
}
