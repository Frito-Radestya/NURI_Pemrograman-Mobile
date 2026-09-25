/// Data anak yang dipakai sebagai modul CRUD kedua dan direlasikan dengan
/// food diary melalui [ChildProfile.id].
class ChildProfile {
  final String id;
  final String ownerUserId;
  final String name;
  final DateTime birthDate;
  final String gender; // 'L' atau 'P'
  final double weightKg;
  final double heightCm;
  final String motherName;
  final DateTime lastCheckDate;
  final String status; // Normal | Perlu Pemantauan | Risiko Stunting
  final String notes;

  const ChildProfile({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.motherName,
    required this.lastCheckDate,
    required this.status,
    this.notes = '',
  });

  int ageInMonths(DateTime reference) {
    var months =
        (reference.year - birthDate.year) * 12 +
        reference.month -
        birthDate.month;
    if (reference.day < birthDate.day) months--;
    return months < 0 ? 0 : months;
  }

  String ageLabel([DateTime? reference]) {
    final totalMonths = ageInMonths(reference ?? DateTime.now());
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;
    if (years == 0) return '$months bulan';
    return months == 0 ? '$years tahun' : '$years tahun $months bulan';
  }

  String get genderLabel => gender == 'L' ? 'Laki-laki' : 'Perempuan';

  String get statusLabel => status;

  ChildProfile copyWith({
    String? id,
    String? ownerUserId,
    String? name,
    DateTime? birthDate,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? motherName,
    DateTime? lastCheckDate,
    String? status,
    String? notes,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      motherName: motherName ?? this.motherName,
      lastCheckDate: lastCheckDate ?? this.lastCheckDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'motherName': motherName,
      'lastCheckDate': lastCheckDate.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] ?? '',
      ownerUserId: map['ownerUserId'] ?? 'guest',
      name: map['name'] ?? '',
      birthDate:
          DateTime.tryParse(map['birthDate'] ?? '') ?? DateTime(2023, 1, 1),
      gender: map['gender'] == 'P' ? 'P' : 'L',
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0,
      motherName: map['motherName'] ?? '',
      lastCheckDate:
          DateTime.tryParse(map['lastCheckDate'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Perlu Pemantauan',
      notes: map['notes'] ?? '',
    );
  }
}
