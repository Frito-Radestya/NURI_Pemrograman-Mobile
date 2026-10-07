import '../engines/age_calculator.dart';
import 'guardian_consent.dart';
import 'sex.dart';

/// Data anak (PRD Bagian 8, tabel `children`).
///
/// Hanya nama panggilan yang disimpan, bukan nama lengkap (PRD Bagian 11).
class Child {
  const Child({
    required this.id,
    required this.createdBy,
    required this.nickname,
    required this.birthDate,
    required this.sex,
    this.posyanduName,
    this.consent,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId = 'device-lokal',
  });

  final String id;
  final String createdBy;
  final String nickname;
  final DateTime birthDate;
  final Sex sex;
  final String? posyanduName;
  final GuardianConsent? consent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;

  int ageInMonthsAt(DateTime at) => AgeCalculator.inMonths(birthDate, at);

  String ageLabelAt(DateTime at) =>
      AgeCalculator.label(ageInMonthsAt(at));

  String get initial {
    if (nickname.trim().isEmpty) return '?';
    return nickname.trim().charactersFirst.toUpperCase();
  }

  Child copyWith({
    String? nickname,
    DateTime? birthDate,
    Sex? sex,
    String? posyanduName,
    GuardianConsent? consent,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Child(
      id: id,
      createdBy: createdBy,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      posyanduName: posyanduName ?? this.posyanduName,
      consent: consent ?? this.consent,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId,
    );
  }
}

extension on String {
  /// Karakter pertama yang aman untuk avatar teks.
  String get charactersFirst => runes.isEmpty
      ? '?'
      : String.fromCharCode(runes.first);
}
