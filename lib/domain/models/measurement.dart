/// Metode pengukuran (PRD Bagian 6).
enum MeasureMethod {
  berbaring('Berbaring (PB)', 'Berbaring'),
  berdiri('Berdiri (TB)', 'Berdiri');

  const MeasureMethod(this.label, this.shortLabel);

  final String label;
  final String shortLabel;

  String get code => name;

  static MeasureMethod fromCode(String? code) =>
      MeasureMethod.values.firstWhere(
        (MeasureMethod m) => m.name == code,
        orElse: () => MeasureMethod.berbaring,
      );

  /// Metode yang dianjurkan menurut umur: < 24 bulan berbaring, >= 24 berdiri.
  static MeasureMethod recommendedFor(int ageMonths) =>
      ageMonths < 24 ? MeasureMethod.berbaring : MeasureMethod.berdiri;

  /// Metode menurut umur (hari). WHO berpindah dari panjang (berbaring) ke
  /// tinggi (berdiri) pada hari ke-731.
  static MeasureMethod recommendedForDays(int ageDays) =>
      ageDays <= 730 ? MeasureMethod.berbaring : MeasureMethod.berdiri;
}

/// Satu pengukuran anak. Append-only: pengukuran baru = baris baru (PRD).
class Measurement {
  const Measurement({
    required this.id,
    required this.childId,
    this.sessionId,
    required this.measuredOn,
    required this.ageMonths,
    required this.weightKg,
    required this.lengthHeightCm,
    required this.method,
    required this.adjustedCm,
    required this.recordedBy,
    required this.createdAt,
  });

  final String id;
  final String childId;
  final String? sessionId;
  final DateTime measuredOn;
  final int ageMonths;
  final double weightKg;
  final double lengthHeightCm;
  final MeasureMethod method;
  final double adjustedCm;
  final String recordedBy;
  final DateTime createdAt;
}
