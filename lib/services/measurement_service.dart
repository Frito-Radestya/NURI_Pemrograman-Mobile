import 'who_service.dart';

/// Satu pengukuran tersimpan (riwayat, tidak menimpa - F-04.6).
class Measurement {
  final String id;
  final String childId;
  final DateTime date;
  final int ageMonths;
  final double weightKg;
  final double measuredCm;
  final double correctedCm;
  final bool isLength;
  final double zScore;
  final String category;

  const Measurement({
    required this.id,
    required this.childId,
    required this.date,
    required this.ageMonths,
    required this.weightKg,
    required this.measuredCm,
    required this.correctedCm,
    required this.isLength,
    required this.zScore,
    required this.category,
  });
}

/// Riwayat pengukuran per anak (in-memory, siap ganti Supabase).
class MeasurementService {
  static final MeasurementService _instance = MeasurementService._internal();
  factory MeasurementService() => _instance;
  MeasurementService._internal();

  final Map<String, List<Measurement>> _byChild = {};
  int _counter = 0;

  List<Measurement> forChild(String childId) {
    final list = _byChild[childId] ?? const <Measurement>[];
    final sorted = [...list]..sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(sorted);
  }

  Measurement add({
    required String childId,
    required DateTime date,
    required double weightKg,
    required ScreeningResult result,
  }) {
    _counter++;
    final m = Measurement(
      id: 'msr_${DateTime.now().millisecondsSinceEpoch}_$_counter',
      childId: childId,
      date: date,
      ageMonths: result.ageMonths,
      weightKg: weightKg,
      measuredCm: result.measuredCm,
      correctedCm: result.correctedCm,
      isLength: result.isLength,
      zScore: result.zScore,
      category: result.category,
    );
    _byChild.putIfAbsent(childId, () => []).add(m);
    return m;
  }

  void clear() => _byChild.clear();
}
