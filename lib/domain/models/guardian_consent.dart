/// Metode persetujuan wali (PRD Bagian 3, OQ-9).
enum ConsentMethod {
  lisan('Lisan'),
  kertas('Kertas'),
  aplikasi('Aplikasi');

  const ConsentMethod(this.label);

  final String label;

  String get code => name;

  static ConsentMethod fromCode(String? code) => ConsentMethod.values.firstWhere(
    (ConsentMethod m) => m.name == code,
    orElse: () => ConsentMethod.lisan,
  );
}

/// Persetujuan wali per anak. Wajib sebelum kader menyimpan anak (F3).
class GuardianConsent {
  const GuardianConsent({
    required this.method,
    required this.consentedAt,
    required this.recordedBy,
  });

  final ConsentMethod method;
  final DateTime consentedAt;
  final String recordedBy;
}
