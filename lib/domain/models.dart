import 'dart:math' as math;

/// Nilai gizi dan antropometri disimpan sebagai angka desimal.
/// Semua tanggal disimpan sebagai tanggal kalender (tanpa jam) kecuali createdAt.
String dateToIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime? parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return dateOnly(value);
  return DateTime.tryParse(value.toString());
}

double? parseDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? parseInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<String> _stringList(Object? value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

enum UserRole {
  mother('ibu', 'Ibu'),
  cadre('kader', 'Kader');

  const UserRole(this.storage, this.label);
  final String storage;
  final String label;

  static UserRole fromStorage(String? value) => UserRole.values.firstWhere(
    (e) => e.storage == value,
    orElse: () => UserRole.mother,
  );
}

enum Sex {
  male('L', 'Laki-laki'),
  female('P', 'Perempuan');

  const Sex(this.short, this.label);
  final String short;
  final String label;

  static Sex fromStorage(String? value) =>
      value == 'P' || value == 'female' ? Sex.female : Sex.male;
}

enum MeasurementMethod {
  lying('berbaring', 'Berbaring (PB)'),
  standing('berdiri', 'Berdiri (TB)');

  const MeasurementMethod(this.storage, this.label);
  final String storage;
  final String label;

  static MeasurementMethod fromStorage(String? value) =>
      value == 'berdiri' || value == 'standing'
      ? MeasurementMethod.standing
      : MeasurementMethod.lying;
}

enum GrowthCategory {
  severelyStunted('sangat_pendek', 'Sangat Pendek', 'Rujuk Faskes'),
  stunted('pendek', 'Pendek', 'Pantau Nutrisi'),
  normal('normal', 'Normal', 'Optimal & Sehat'),
  tall('tinggi', 'Tinggi', 'Pantau');

  const GrowthCategory(this.storage, this.label, this.shortAdvice);
  final String storage;
  final String label;
  final String shortAdvice;

  static GrowthCategory fromStorage(String? value) =>
      GrowthCategory.values.firstWhere(
        (e) => e.storage == value,
        orElse: () => GrowthCategory.normal,
      );

  bool get needsFollowUp =>
      this == GrowthCategory.stunted || this == GrowthCategory.severelyStunted;

  /// Label ramah keluarga untuk layar harian. Istilah klinis tetap dipakai
  /// pada layar skrining dan rujukan.
  String get plainLabel => switch (this) {
    GrowthCategory.normal => 'Tumbuh optimal',
    GrowthCategory.stunted => 'Perlu perhatian',
    GrowthCategory.severelyStunted => 'Perlu rujukan',
    GrowthCategory.tall => 'Tinggi, tetap pantau',
  };
}

enum PregnancyStatus {
  active('aktif'),
  born('lahir'),
  ended('berakhir');

  const PregnancyStatus(this.storage);
  final String storage;

  static PregnancyStatus fromStorage(String? value) =>
      PregnancyStatus.values.firstWhere(
        (e) => e.storage == value,
        orElse: () => PregnancyStatus.active,
      );
}

enum MealType {
  breakfast('pagi', 'Sarapan'),
  lunch('siang', 'Makan Siang'),
  dinner('malam', 'Makan Malam'),
  snack('snack', 'Selingan');

  const MealType(this.storage, this.label);
  final String storage;
  final String label;

  static MealType fromStorage(String? value) => MealType.values.firstWhere(
    (e) => e.storage == value,
    orElse: () => MealType.lunch,
  );
}

enum FoodSource {
  manual('manual', 'Input manual'),
  ai('ai', 'Deteksi AI'),
  recipe('resep', 'Resep');

  const FoodSource(this.storage, this.label);
  final String storage;
  final String label;

  static FoodSource fromStorage(String? value) => FoodSource.values.firstWhere(
    (e) => e.storage == value,
    orElse: () => FoodSource.manual,
  );
}

enum RosterType {
  child('anak', 'Balita'),
  pregnant('bumil', 'Ibu Hamil');

  const RosterType(this.storage, this.label);
  final String storage;
  final String label;

  static RosterType fromStorage(String? value) =>
      value == 'bumil' ? RosterType.pregnant : RosterType.child;
}

enum AttendanceStatus {
  present('hadir', 'Selesai'),
  waiting('menunggu', 'Menunggu Ukur'),
  absent('tidak_hadir', 'Belum Hadir');

  const AttendanceStatus(this.storage, this.label);
  final String storage;
  final String label;

  static AttendanceStatus fromStorage(String? value) =>
      AttendanceStatus.values.firstWhere(
        (e) => e.storage == value,
        orElse: () => AttendanceStatus.waiting,
      );
}

enum FollowUpStatus {
  open('terbuka', 'Perlu Tindak Lanjut'),
  visited('dikunjungi', 'Sudah Dikunjungi'),
  referred('dirujuk', 'Dirujuk ke Faskes'),
  unreachable('tidak_ditemui', 'Tidak Dapat Ditemui'),
  closed('selesai', 'Selesai');

  const FollowUpStatus(this.storage, this.label);
  final String storage;
  final String label;

  static FollowUpStatus fromStorage(String? value) => FollowUpStatus.values
      .firstWhere((e) => e.storage == value, orElse: () => FollowUpStatus.open);
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.posyanduId,
    this.avatarAsset,
    this.demo = true,
    this.authUid,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? posyanduId;
  final String? avatarAsset;
  final bool demo;

  /// UID Firebase Authentication. Akun demo lama tetap memakai id lokal
  /// (`u_ibu`, `u_kader`) agar data yang sudah ada tidak perlu dimigrasikan;
  /// UID ini menjadi jembatan saat Firestore diaktifkan.
  final String? authUid;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.storage,
    'posyanduId': posyanduId,
    'avatarAsset': avatarAsset,
    'demo': demo,
    'authUid': authUid,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Pengguna NURI',
    email: json['email'] as String? ?? '',
    role: UserRole.fromStorage(json['role'] as String?),
    posyanduId: json['posyanduId'] as String?,
    avatarAsset: json['avatarAsset'] as String?,
    demo: json['demo'] as bool? ?? true,
    authUid: json['authUid'] as String?,
  );
}

class Checkup {
  const Checkup({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.lilaCm,
    this.hbGdl,
    this.systolic,
    this.diastolic,
    this.source = 'mandiri',
    this.recordedBy = 'Ibu',
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final double lilaCm;
  final double? hbGdl;
  final int? systolic;
  final int? diastolic;
  final String source;
  final String recordedBy;

  bool get needsConsultation =>
      lilaCm < 23.5 || (hbGdl != null && hbGdl! < 11.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': dateToIso(date),
    'weightKg': weightKg,
    'lilaCm': lilaCm,
    'hbGdl': hbGdl,
    'systolic': systolic,
    'diastolic': diastolic,
    'source': source,
    'recordedBy': recordedBy,
  };

  factory Checkup.fromJson(Map<String, dynamic> json) => Checkup(
    id: json['id'] as String,
    date: parseDate(json['date']) ?? DateTime.now(),
    weightKg: parseDouble(json['weightKg']) ?? 0,
    lilaCm: parseDouble(json['lilaCm']) ?? 0,
    hbGdl: parseDouble(json['hbGdl']),
    systolic: parseInt(json['systolic']),
    diastolic: parseInt(json['diastolic']),
    source: json['source'] as String? ?? 'mandiri',
    recordedBy: json['recordedBy'] as String? ?? 'Ibu',
  );
}

class AncVisit {
  const AncVisit({
    required this.id,
    required this.date,
    this.facility,
    this.note,
  });

  final String id;
  final DateTime date;
  final String? facility;
  final String? note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': dateToIso(date),
    'facility': facility,
    'note': note,
  };

  factory AncVisit.fromJson(Map<String, dynamic> json) => AncVisit(
    id: json['id'] as String,
    date: parseDate(json['date']) ?? DateTime.now(),
    facility: json['facility'] as String?,
    note: json['note'] as String?,
  );
}

class Pregnancy {
  const Pregnancy({
    required this.id,
    required this.ownerUid,
    required this.hpht,
    required this.hpl,
    this.status = PregnancyStatus.active,
    this.childId,
    this.checkups = const [],
    this.ttdDates = const [],
    this.ancVisits = const [],
    this.createdAt,
  });

  final String id;
  final String ownerUid;
  final DateTime hpht;
  final DateTime hpl;
  final PregnancyStatus status;
  final String? childId;
  final List<Checkup> checkups;
  final List<String> ttdDates;
  final List<AncVisit> ancVisits;
  final DateTime? createdAt;

  Checkup? get latestCheckup => checkups.isEmpty
      ? null
      : (List<Checkup>.from(
          checkups,
        )..sort((a, b) => b.date.compareTo(a.date))).first;

  int get ttdCount => ttdDates.toSet().length;
  int get ancCount => ancVisits.length;

  Pregnancy copyWith({
    String? id,
    String? ownerUid,
    DateTime? hpht,
    DateTime? hpl,
    PregnancyStatus? status,
    String? childId,
    bool clearChildId = false,
    List<Checkup>? checkups,
    List<String>? ttdDates,
    List<AncVisit>? ancVisits,
    DateTime? createdAt,
  }) => Pregnancy(
    id: id ?? this.id,
    ownerUid: ownerUid ?? this.ownerUid,
    hpht: hpht ?? this.hpht,
    hpl: hpl ?? this.hpl,
    status: status ?? this.status,
    childId: clearChildId ? null : (childId ?? this.childId),
    checkups: checkups ?? this.checkups,
    ttdDates: ttdDates ?? this.ttdDates,
    ancVisits: ancVisits ?? this.ancVisits,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerUid': ownerUid,
    'hpht': dateToIso(hpht),
    'hpl': dateToIso(hpl),
    'status': status.storage,
    'childId': childId,
    'checkups': checkups.map((e) => e.toJson()).toList(),
    'ttdDates': ttdDates,
    'ancVisits': ancVisits.map((e) => e.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Pregnancy.fromJson(Map<String, dynamic> json) => Pregnancy(
    id: json['id'] as String,
    ownerUid: json['ownerUid'] as String? ?? '',
    hpht: parseDate(json['hpht']) ?? DateTime.now(),
    hpl:
        parseDate(json['hpl']) ?? DateTime.now().add(const Duration(days: 280)),
    status: PregnancyStatus.fromStorage(json['status'] as String?),
    childId: json['childId'] as String?,
    checkups: (json['checkups'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Checkup.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    ttdDates: _stringList(json['ttdDates']),
    ancVisits: (json['ancVisits'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AncVisit.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    createdAt: parseDate(json['createdAt']),
  );
}

class Measurement {
  const Measurement({
    required this.id,
    required this.date,
    required this.ageDays,
    required this.ageMonths,
    required this.weightKg,
    required this.measuredCm,
    required this.method,
    required this.correctedCm,
    required this.zHfa,
    required this.category,
    required this.source,
    this.recordedByUid,
    this.sessionId,
    this.flags = const [],
    this.synced = true,
    this.createdAt,
  });

  final String id;
  final DateTime date;
  final int ageDays;
  final int ageMonths;
  final double weightKg;
  final double measuredCm;
  final MeasurementMethod method;
  final double correctedCm;
  final double zHfa;
  final GrowthCategory category;
  final String source;
  final String? recordedByUid;
  final String? sessionId;
  final List<String> flags;
  final bool synced;
  final DateTime? createdAt;

  /// Catatan koreksi metode ukur diturunkan dari flag agar tetap tersimpan
  /// pada data lama tanpa menambah field baru.
  String? get correctionNote {
    if (flags.contains('Koreksi PB +0,7 cm')) {
      return 'Diukur berdiri pada usia < 24 bulan. Panjang badan dikoreksi +0,7 cm.';
    }
    if (flags.contains('Koreksi TB −0,7 cm')) {
      return 'Diukur berbaring pada usia ≥ 24 bulan. Tinggi badan dikoreksi −0,7 cm.';
    }
    return null;
  }

  bool get implausible => flags.any((flag) => flag.contains('di luar ±6'));

  Measurement copyWith({bool? synced, List<String>? flags}) => Measurement(
    id: id,
    date: date,
    ageDays: ageDays,
    ageMonths: ageMonths,
    weightKg: weightKg,
    measuredCm: measuredCm,
    method: method,
    correctedCm: correctedCm,
    zHfa: zHfa,
    category: category,
    source: source,
    recordedByUid: recordedByUid,
    sessionId: sessionId,
    flags: flags ?? this.flags,
    synced: synced ?? this.synced,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': dateToIso(date),
    'ageDays': ageDays,
    'ageMonths': ageMonths,
    'weightKg': weightKg,
    'measuredCm': measuredCm,
    'method': method.storage,
    'correctedCm': correctedCm,
    'zHfa': zHfa,
    'category': category.storage,
    'source': source,
    'recordedByUid': recordedByUid,
    'sessionId': sessionId,
    'flags': flags,
    'synced': synced,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
    id: json['id'] as String,
    date: parseDate(json['date']) ?? DateTime.now(),
    ageDays: parseInt(json['ageDays']) ?? 0,
    ageMonths: parseInt(json['ageMonths']) ?? 0,
    weightKg: parseDouble(json['weightKg']) ?? 0,
    measuredCm: parseDouble(json['measuredCm']) ?? 0,
    method: MeasurementMethod.fromStorage(json['method'] as String?),
    correctedCm: parseDouble(json['correctedCm']) ?? 0,
    zHfa: parseDouble(json['zHfa']) ?? 0,
    category: GrowthCategory.fromStorage(json['category'] as String?),
    source: json['source'] as String? ?? 'mandiri',
    recordedByUid: json['recordedByUid'] as String?,
    sessionId: json['sessionId'] as String?,
    flags: _stringList(json['flags']),
    synced: json['synced'] as bool? ?? true,
    createdAt: parseDate(json['createdAt']),
  );
}

class Child {
  const Child({
    required this.id,
    required this.nickname,
    required this.dob,
    required this.sex,
    required this.guardianName,
    this.guardianUid,
    this.posyanduId,
    this.birthWeightKg,
    this.birthLengthCm,
    this.archived = false,
    this.linked = false,
    this.measurements = const [],
    this.avatarIndex = 0,
  });

  final String id;
  final String nickname;
  final DateTime dob;
  final Sex sex;
  final String guardianName;
  final String? guardianUid;
  final String? posyanduId;
  final double? birthWeightKg;
  final double? birthLengthCm;
  final bool archived;
  final bool linked;
  final List<Measurement> measurements;
  final int avatarIndex;

  int ageDaysAt(DateTime date) =>
      dateOnly(date).difference(dateOnly(dob)).inDays;

  int ageMonthsAt(DateTime date) {
    final days = ageDaysAt(date);
    if (days < 0) return 0;
    return (days / 30.4375).floor();
  }

  String ageLabel([DateTime? at]) {
    final date = at ?? DateTime.now();
    final days = ageDaysAt(date);
    if (days < 0) return 'Belum lahir';
    if (days < 31) return '$days Hari';
    final months = (days / 30.4375).floor();
    if (months < 24) return '$months Bulan';
    final years = months ~/ 12;
    final rest = months % 12;
    return rest == 0 ? '$years Tahun' : '$years Thn $rest Bln';
  }

  Measurement? get latestMeasurement {
    if (measurements.isEmpty) return null;
    final sorted = List<Measurement>.from(measurements)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  Measurement? get previousMeasurement {
    if (measurements.length < 2) return null;
    final sorted = List<Measurement>.from(measurements)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted[1];
  }

  Child copyWith({
    String? id,
    String? nickname,
    DateTime? dob,
    Sex? sex,
    String? guardianName,
    String? guardianUid,
    String? posyanduId,
    double? birthWeightKg,
    double? birthLengthCm,
    bool? archived,
    bool? linked,
    List<Measurement>? measurements,
    int? avatarIndex,
  }) => Child(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    dob: dob ?? this.dob,
    sex: sex ?? this.sex,
    guardianName: guardianName ?? this.guardianName,
    guardianUid: guardianUid ?? this.guardianUid,
    posyanduId: posyanduId ?? this.posyanduId,
    birthWeightKg: birthWeightKg ?? this.birthWeightKg,
    birthLengthCm: birthLengthCm ?? this.birthLengthCm,
    archived: archived ?? this.archived,
    linked: linked ?? this.linked,
    measurements: measurements ?? this.measurements,
    avatarIndex: avatarIndex ?? this.avatarIndex,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'dob': dateToIso(dob),
    'sex': sex.short,
    'guardianName': guardianName,
    'guardianUid': guardianUid,
    'posyanduId': posyanduId,
    'birthWeightKg': birthWeightKg,
    'birthLengthCm': birthLengthCm,
    'archived': archived,
    'linked': linked,
    'measurements': measurements.map((e) => e.toJson()).toList(),
    'avatarIndex': avatarIndex,
  };

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json['id'] as String,
    nickname: json['nickname'] as String? ?? 'Anak',
    dob: parseDate(json['dob']) ?? DateTime.now(),
    sex: Sex.fromStorage(json['sex'] as String?),
    guardianName: json['guardianName'] as String? ?? '',
    guardianUid: json['guardianUid'] as String?,
    posyanduId: json['posyanduId'] as String?,
    birthWeightKg: parseDouble(json['birthWeightKg']),
    birthLengthCm: parseDouble(json['birthLengthCm']),
    archived: json['archived'] as bool? ?? false,
    linked: json['linked'] as bool? ?? false,
    measurements: (json['measurements'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Measurement.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    avatarIndex: parseInt(json['avatarIndex']) ?? 0,
  );
}

class FoodLogItem {
  const FoodLogItem({
    required this.foodId,
    required this.name,
    required this.grams,
    this.kcalPer100,
    this.proteinPer100,
    this.fatPer100,
    this.carbPer100,
    this.ironPer100,
    this.zincPer100,
    this.source = FoodSource.manual,
    this.confidence,
  });

  final String foodId;
  final String name;
  final double grams;
  final double? kcalPer100;
  final double? proteinPer100;
  final double? fatPer100;
  final double? carbPer100;
  final double? ironPer100;
  final double? zincPer100;
  final FoodSource source;
  final double? confidence;

  double? _value(double? per100) =>
      per100 == null ? null : (grams / 100.0) * per100;

  double? get kcal => _value(kcalPer100);
  double? get proteinG => _value(proteinPer100);
  double? get fatG => _value(fatPer100);
  double? get carbG => _value(carbPer100);
  double? get ironMg => _value(ironPer100);
  double? get zincMg => _value(zincPer100);

  FoodLogItem copyWith({double? grams, FoodSource? source}) => FoodLogItem(
    foodId: foodId,
    name: name,
    grams: grams ?? this.grams,
    kcalPer100: kcalPer100,
    proteinPer100: proteinPer100,
    fatPer100: fatPer100,
    carbPer100: carbPer100,
    ironPer100: ironPer100,
    zincPer100: zincPer100,
    source: source ?? this.source,
    confidence: confidence,
  );

  Map<String, dynamic> toJson() => {
    'foodId': foodId,
    'name': name,
    'grams': grams,
    'kcalPer100': kcalPer100,
    'proteinPer100': proteinPer100,
    'fatPer100': fatPer100,
    'carbPer100': carbPer100,
    'ironPer100': ironPer100,
    'zincPer100': zincPer100,
    'source': source.storage,
    'confidence': confidence,
  };

  factory FoodLogItem.fromJson(Map<String, dynamic> json) => FoodLogItem(
    foodId: json['foodId'] as String? ?? '',
    name: json['name'] as String? ?? 'Makanan',
    grams: parseDouble(json['grams']) ?? 0,
    kcalPer100: parseDouble(json['kcalPer100']),
    proteinPer100: parseDouble(json['proteinPer100']),
    fatPer100: parseDouble(json['fatPer100']),
    carbPer100: parseDouble(json['carbPer100']),
    ironPer100: parseDouble(json['ironPer100']),
    zincPer100: parseDouble(json['zincPer100']),
    source: FoodSource.fromStorage(json['source'] as String?),
    confidence: parseDouble(json['confidence']),
  );
}

class NutritionTotals {
  const NutritionTotals({
    this.kcal,
    this.proteinG,
    this.fatG,
    this.carbG,
    this.ironMg,
    this.zincMg,
    this.incomplete = false,
    this.incompleteNutrients = const [],
  });

  final double? kcal;
  final double? proteinG;
  final double? fatG;
  final double? carbG;
  final double? ironMg;
  final double? zincMg;
  final bool incomplete;
  final List<String> incompleteNutrients;

  Map<String, dynamic> toJson() => {
    'kcal': kcal,
    'proteinG': proteinG,
    'fatG': fatG,
    'carbG': carbG,
    'ironMg': ironMg,
    'zincMg': zincMg,
    'incomplete': incomplete,
    'incompleteNutrients': incompleteNutrients,
  };

  factory NutritionTotals.fromJson(Map<String, dynamic> json) =>
      NutritionTotals(
        kcal: parseDouble(json['kcal']),
        proteinG: parseDouble(json['proteinG']),
        fatG: parseDouble(json['fatG']),
        carbG: parseDouble(json['carbG']),
        ironMg: parseDouble(json['ironMg']),
        zincMg: parseDouble(json['zincMg']),
        incomplete: json['incomplete'] as bool? ?? false,
        incompleteNutrients: _stringList(json['incompleteNutrients']),
      );

  static NutritionTotals fromItems(List<FoodLogItem> items) {
    if (items.isEmpty) return const NutritionTotals();
    double? sum(
      double? Function(FoodLogItem) getter,
      String label,
      List<String> missing,
    ) {
      var total = 0.0;
      var hasValue = false;
      for (final item in items) {
        final v = getter(item);
        if (v == null) {
          if (!missing.contains(label)) missing.add(label);
        } else {
          total += v;
          hasValue = true;
        }
      }
      return hasValue ? total : null;
    }

    final missing = <String>[];
    return NutritionTotals(
      kcal: sum((e) => e.kcal, 'energi', missing),
      proteinG: sum((e) => e.proteinG, 'protein', missing),
      fatG: sum((e) => e.fatG, 'lemak', missing),
      carbG: sum((e) => e.carbG, 'karbohidrat', missing),
      ironMg: sum((e) => e.ironMg, 'zat besi', missing),
      zincMg: sum((e) => e.zincMg, 'zink', missing),
      incomplete: missing.isNotEmpty,
      incompleteNutrients: missing,
    );
  }
}

class FoodLog {
  const FoodLog({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.meal,
    required this.items,
    this.note,
    this.createdAt,
    this.tkpiVersion = 'tkpi-2017-subset-v1',
  });

  final String id;
  final String subjectId;
  final DateTime date;
  final MealType meal;
  final List<FoodLogItem> items;
  final String? note;
  final DateTime? createdAt;
  final String tkpiVersion;

  NutritionTotals get totals => NutritionTotals.fromItems(items);

  FoodLog copyWith({List<FoodLogItem>? items, String? note, MealType? meal}) =>
      FoodLog(
        id: id,
        subjectId: subjectId,
        date: date,
        meal: meal ?? this.meal,
        items: items ?? this.items,
        note: note ?? this.note,
        createdAt: createdAt,
        tkpiVersion: tkpiVersion,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'date': dateToIso(date),
    'meal': meal.storage,
    'items': items.map((e) => e.toJson()).toList(),
    'note': note,
    'createdAt': createdAt?.toIso8601String(),
    'tkpiVersion': tkpiVersion,
  };

  factory FoodLog.fromJson(Map<String, dynamic> json) => FoodLog(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String? ?? '',
    date: parseDate(json['date']) ?? DateTime.now(),
    meal: MealType.fromStorage(json['meal'] as String?),
    items: (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => FoodLogItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    note: json['note'] as String?,
    createdAt: parseDate(json['createdAt']),
    tkpiVersion: json['tkpiVersion'] as String? ?? 'tkpi-2017-subset-v1',
  );
}

class ContentArticle {
  const ContentArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.body,
    required this.category,
    this.imageAsset,
    this.readMinutes = 3,
    this.source = 'Kemenkes RI',
    this.reviewedBy = 'Tim NURI',
    this.targetStatus,
    this.ageMinMonths,
    this.ageMaxMonths,
    this.published = true,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String excerpt;
  final String body;
  final String category;
  final String? imageAsset;
  final int readMinutes;
  final String source;
  final String reviewedBy;
  final String? targetStatus;
  final int? ageMinMonths;
  final int? ageMaxMonths;
  final bool published;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'excerpt': excerpt,
    'body': body,
    'category': category,
    'imageAsset': imageAsset,
    'readMinutes': readMinutes,
    'source': source,
    'reviewedBy': reviewedBy,
    'targetStatus': targetStatus,
    'ageMinMonths': ageMinMonths,
    'ageMaxMonths': ageMaxMonths,
    'published': published,
    'tags': tags,
  };

  factory ContentArticle.fromJson(Map<String, dynamic> json) => ContentArticle(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    excerpt: json['excerpt'] as String? ?? '',
    body: json['body'] as String? ?? '',
    category: json['category'] as String? ?? 'Edukasi',
    imageAsset: json['imageAsset'] as String?,
    readMinutes: parseInt(json['readMinutes']) ?? 3,
    source: json['source'] as String? ?? 'Kemenkes RI',
    reviewedBy: json['reviewedBy'] as String? ?? 'Tim NURI',
    targetStatus: json['targetStatus'] as String?,
    ageMinMonths: parseInt(json['ageMinMonths']),
    ageMaxMonths: parseInt(json['ageMaxMonths']),
    published: json['published'] as bool? ?? true,
    tags: _stringList(json['tags']),
  );
}

class RosterEntry {
  const RosterEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.attendance,
    required this.avatarIndex,
    this.posyanduId,
    this.subjectId,
    this.guardianName = '',
    this.ageMonths,
    this.pregnancyWeeks,
    this.sex,
    this.category,
    this.priority = false,
    this.reason,
    this.followUpStatus = FollowUpStatus.open,
    this.linked = false,
    this.lastMeasuredAt,
    this.sessionId,
    this.pendingSync = false,
    this.lilaCm,
    this.hbGdl,
  });

  final String id;
  final String name;
  final RosterType type;
  final AttendanceStatus attendance;
  final int avatarIndex;
  final String? posyanduId;
  final String? subjectId;
  final String guardianName;
  final int? ageMonths;
  final int? pregnancyWeeks;
  final Sex? sex;
  final GrowthCategory? category;
  final bool priority;
  final String? reason;
  final FollowUpStatus followUpStatus;
  final bool linked;
  final DateTime? lastMeasuredAt;
  final String? sessionId;
  final bool pendingSync;
  final double? lilaCm;
  final double? hbGdl;

  bool get needsFollowUp =>
      followUpStatus != FollowUpStatus.closed &&
      (priority ||
          attendance == AttendanceStatus.absent ||
          (category?.needsFollowUp ?? false) ||
          (lilaCm != null && lilaCm! < 23.5) ||
          (hbGdl != null && hbGdl! < 11));

  RosterEntry copyWith({
    String? name,
    AttendanceStatus? attendance,
    GrowthCategory? category,
    bool? priority,
    String? reason,
    FollowUpStatus? followUpStatus,
    DateTime? lastMeasuredAt,
    bool? pendingSync,
    int? ageMonths,
    double? lilaCm,
    double? hbGdl,
    String? posyanduId,
  }) => RosterEntry(
    id: id,
    name: name ?? this.name,
    type: type,
    attendance: attendance ?? this.attendance,
    avatarIndex: avatarIndex,
    posyanduId: posyanduId ?? this.posyanduId,
    subjectId: subjectId,
    guardianName: guardianName,
    ageMonths: ageMonths ?? this.ageMonths,
    pregnancyWeeks: pregnancyWeeks,
    sex: sex,
    category: category ?? this.category,
    priority: priority ?? this.priority,
    reason: reason ?? this.reason,
    followUpStatus: followUpStatus ?? this.followUpStatus,
    linked: linked,
    lastMeasuredAt: lastMeasuredAt ?? this.lastMeasuredAt,
    sessionId: sessionId,
    pendingSync: pendingSync ?? this.pendingSync,
    lilaCm: lilaCm ?? this.lilaCm,
    hbGdl: hbGdl ?? this.hbGdl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.storage,
    'attendance': attendance.storage,
    'avatarIndex': avatarIndex,
    'posyanduId': posyanduId,
    'subjectId': subjectId,
    'guardianName': guardianName,
    'ageMonths': ageMonths,
    'pregnancyWeeks': pregnancyWeeks,
    'sex': sex?.short,
    'category': category?.storage,
    'priority': priority,
    'reason': reason,
    'followUpStatus': followUpStatus.storage,
    'linked': linked,
    'lastMeasuredAt': lastMeasuredAt == null
        ? null
        : dateToIso(lastMeasuredAt!),
    'sessionId': sessionId,
    'pendingSync': pendingSync,
    'lilaCm': lilaCm,
    'hbGdl': hbGdl,
  };

  factory RosterEntry.fromJson(Map<String, dynamic> json) => RosterEntry(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    type: RosterType.fromStorage(json['type'] as String?),
    attendance: AttendanceStatus.fromStorage(json['attendance'] as String?),
    avatarIndex: parseInt(json['avatarIndex']) ?? 0,
    posyanduId: json['posyanduId'] as String?,
    subjectId: json['subjectId'] as String?,
    guardianName: json['guardianName'] as String? ?? '',
    ageMonths: parseInt(json['ageMonths']),
    pregnancyWeeks: parseInt(json['pregnancyWeeks']),
    sex: json['sex'] == null ? null : Sex.fromStorage(json['sex'] as String?),
    category: json['category'] == null
        ? null
        : GrowthCategory.fromStorage(json['category'] as String?),
    priority: json['priority'] as bool? ?? false,
    reason: json['reason'] as String?,
    followUpStatus: FollowUpStatus.fromStorage(
      json['followUpStatus'] as String?,
    ),
    linked: json['linked'] as bool? ?? false,
    lastMeasuredAt: parseDate(json['lastMeasuredAt']),
    sessionId: json['sessionId'] as String?,
    pendingSync: json['pendingSync'] as bool? ?? false,
    lilaCm: parseDouble(json['lilaCm']),
    hbGdl: parseDouble(json['hbGdl']),
  );
}

class PosyanduSession {
  const PosyanduSession({
    required this.id,
    required this.posyanduName,
    required this.date,
    required this.targetCount,
    required this.presentCount,
    this.status = 'berlangsung',
    this.createdByUid,
    this.note,
  });

  final String id;
  final String posyanduName;
  final DateTime date;
  final int targetCount;
  final int presentCount;
  final String status;
  final String? createdByUid;
  final String? note;

  double get progress => targetCount == 0 ? 0 : presentCount / targetCount;
  bool get isDone => status == 'selesai';

  Map<String, dynamic> toJson() => {
    'id': id,
    'posyanduName': posyanduName,
    'date': dateToIso(date),
    'targetCount': targetCount,
    'presentCount': presentCount,
    'status': status,
    'createdByUid': createdByUid,
    'note': note,
  };

  factory PosyanduSession.fromJson(Map<String, dynamic> json) =>
      PosyanduSession(
        id: json['id'] as String,
        posyanduName: json['posyanduName'] as String? ?? 'Posyandu',
        date: parseDate(json['date']) ?? DateTime.now(),
        targetCount: parseInt(json['targetCount']) ?? 0,
        presentCount: parseInt(json['presentCount']) ?? 0,
        status: json['status'] as String? ?? 'berlangsung',
        createdByUid: json['createdByUid'] as String?,
        note: json['note'] as String?,
      );
}

class AccessGrant {
  const AccessGrant({
    required this.id,
    required this.ownerUid,
    required this.granteeName,
    required this.subjectName,
    required this.scopes,
    required this.createdAt,
    required this.expiresAt,
    this.status = 'aktif',
  });

  final String id;
  final String ownerUid;
  final String granteeName;
  final String subjectName;
  final List<String> scopes;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;

  AccessGrant copyWith({String? status}) => AccessGrant(
    id: id,
    ownerUid: ownerUid,
    granteeName: granteeName,
    subjectName: subjectName,
    scopes: scopes,
    createdAt: createdAt,
    expiresAt: expiresAt,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerUid': ownerUid,
    'granteeName': granteeName,
    'subjectName': subjectName,
    'scopes': scopes,
    'createdAt': dateToIso(createdAt),
    'expiresAt': dateToIso(expiresAt),
    'status': status,
  };

  factory AccessGrant.fromJson(Map<String, dynamic> json) => AccessGrant(
    id: json['id'] as String,
    ownerUid: json['ownerUid'] as String? ?? '',
    granteeName: json['granteeName'] as String? ?? 'Kader',
    subjectName: json['subjectName'] as String? ?? '',
    scopes: _stringList(json['scopes']),
    createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
    expiresAt:
        parseDate(json['expiresAt']) ??
        DateTime.now().add(const Duration(days: 365)),
    status: json['status'] as String? ?? 'aktif',
  );
}

class AppState {
  const AppState({
    required this.users,
    required this.children,
    required this.pregnancies,
    required this.foodLogs,
    required this.roster,
    required this.sessions,
    required this.contents,
    required this.accessGrants,
    this.currentUserId,
    this.selectedChildId,
    this.onboardingSeen = false,
    this.consentAccepted = false,
    this.consentVersion = '2026-11',
    this.pregnancyContext = true,
    this.pendingWrites = 0,
    this.lastSyncAt,
    this.posyanduName = 'Posyandu Melati II',
    this.posyanduArea = 'Kelurahan Sukamaju',
    this.nextPosyanduDate,
    this.landingSeen = false,
    this.readArticles = const {},
    this.mealPlan = const [],
    this.remindersEnabled = true,
  });

  final List<AppUser> users;
  final String? currentUserId;
  final List<Child> children;
  final List<Pregnancy> pregnancies;
  final List<FoodLog> foodLogs;
  final List<RosterEntry> roster;
  final List<PosyanduSession> sessions;
  final List<ContentArticle> contents;
  final List<AccessGrant> accessGrants;
  final String? selectedChildId;
  final bool onboardingSeen;
  final bool consentAccepted;
  final String consentVersion;
  final bool pregnancyContext;
  final int pendingWrites;
  final DateTime? lastSyncAt;
  final String posyanduName;
  final String posyanduArea;
  final DateTime? nextPosyanduDate;
  final bool landingSeen;
  final Set<String> readArticles;
  final List<String> mealPlan;
  final bool remindersEnabled;

  AppUser? get currentUser {
    for (final user in users) {
      if (user.id == currentUserId) return user;
    }
    return null;
  }

  bool get isLoggedIn => currentUser != null;
  bool get isCadre => currentUser?.role == UserRole.cadre;

  List<Child> get myChildren => children
      .where(
        (c) =>
            !c.archived &&
            (c.guardianUid == currentUserId ||
                (currentUser?.role == UserRole.cadre &&
                    c.posyanduId == currentUser?.posyanduId)),
      )
      .toList();

  Child? get activeChild {
    final mine = myChildren;
    if (mine.isEmpty) return null;
    for (final child in mine) {
      if (child.id == selectedChildId) return child;
    }
    return mine.first;
  }

  Pregnancy? get activePregnancy {
    final list = pregnancies
        .where(
          (p) =>
              p.ownerUid == currentUserId && p.status == PregnancyStatus.active,
        )
        .toList();
    if (list.isEmpty) return null;
    return list.first;
  }

  List<FoodLog> foodLogsFor(String subjectId, DateTime date) =>
      foodLogs
          .where(
            (log) =>
                log.subjectId == subjectId &&
                dateToIso(log.date) == dateToIso(date),
          )
          .toList()
        ..sort((a, b) => a.meal.index.compareTo(b.meal.index));

  NutritionTotals totalsFor(String subjectId, DateTime date) =>
      NutritionTotals.fromItems(
        foodLogsFor(subjectId, date).expand((log) => log.items).toList(),
      );

  List<RosterEntry> get myRoster {
    if (currentUser == null) return const [];
    if (currentUser!.demo) {
      return roster;
    }
    return roster
        .where((r) =>
            (r.posyanduId != null && r.posyanduId == currentUser?.posyanduId) ||
            r.guardianName.toLowerCase() == currentUser!.name.toLowerCase())
        .toList();
  }

  PosyanduSession? get activeSession {
    final list = currentUser?.demo == true
        ? sessions
        : sessions
            .where((s) =>
                s.createdByUid == currentUserId ||
                (posyanduName.isNotEmpty && s.posyanduName == posyanduName))
            .toList();
    for (final session in list) {
      if (session.status == 'berlangsung') return session;
    }
    return list.isEmpty ? null : list.first;
  }

  int get followUpCount => myRoster.where((r) => r.needsFollowUp).length;

  AppState copyWith({
    List<AppUser>? users,
    Object? currentUserId = _unset,
    List<Child>? children,
    List<Pregnancy>? pregnancies,
    List<FoodLog>? foodLogs,
    List<RosterEntry>? roster,
    List<PosyanduSession>? sessions,
    List<ContentArticle>? contents,
    List<AccessGrant>? accessGrants,
    Object? selectedChildId = _unset,
    bool? onboardingSeen,
    bool? consentAccepted,
    String? consentVersion,
    bool? pregnancyContext,
    int? pendingWrites,
    Object? lastSyncAt = _unset,
    String? posyanduName,
    String? posyanduArea,
    Object? nextPosyanduDate = _unset,
    bool? landingSeen,
    Set<String>? readArticles,
    List<String>? mealPlan,
    bool? remindersEnabled,
  }) => AppState(
    users: users ?? this.users,
    currentUserId: identical(currentUserId, _unset)
        ? this.currentUserId
        : currentUserId as String?,
    children: children ?? this.children,
    pregnancies: pregnancies ?? this.pregnancies,
    foodLogs: foodLogs ?? this.foodLogs,
    roster: roster ?? this.roster,
    sessions: sessions ?? this.sessions,
    contents: contents ?? this.contents,
    accessGrants: accessGrants ?? this.accessGrants,
    selectedChildId: identical(selectedChildId, _unset)
        ? this.selectedChildId
        : selectedChildId as String?,
    onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    consentAccepted: consentAccepted ?? this.consentAccepted,
    consentVersion: consentVersion ?? this.consentVersion,
    pregnancyContext: pregnancyContext ?? this.pregnancyContext,
    pendingWrites: pendingWrites ?? this.pendingWrites,
    lastSyncAt: identical(lastSyncAt, _unset)
        ? this.lastSyncAt
        : lastSyncAt as DateTime?,
    posyanduName: posyanduName ?? this.posyanduName,
    posyanduArea: posyanduArea ?? this.posyanduArea,
    nextPosyanduDate: identical(nextPosyanduDate, _unset)
        ? this.nextPosyanduDate
        : nextPosyanduDate as DateTime?,
    landingSeen: landingSeen ?? this.landingSeen,
    readArticles: readArticles ?? this.readArticles,
    mealPlan: mealPlan ?? this.mealPlan,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
  );

  Map<String, dynamic> toJson() => {
    'users': users.map((e) => e.toJson()).toList(),
    'currentUserId': currentUserId,
    'children': children.map((e) => e.toJson()).toList(),
    'pregnancies': pregnancies.map((e) => e.toJson()).toList(),
    'foodLogs': foodLogs.map((e) => e.toJson()).toList(),
    'roster': roster.map((e) => e.toJson()).toList(),
    'sessions': sessions.map((e) => e.toJson()).toList(),
    'contents': contents.map((e) => e.toJson()).toList(),
    'accessGrants': accessGrants.map((e) => e.toJson()).toList(),
    'selectedChildId': selectedChildId,
    'onboardingSeen': onboardingSeen,
    'consentAccepted': consentAccepted,
    'consentVersion': consentVersion,
    'pregnancyContext': pregnancyContext,
    'pendingWrites': pendingWrites,
    'lastSyncAt': lastSyncAt?.toIso8601String(),
    'posyanduName': posyanduName,
    'posyanduArea': posyanduArea,
    'nextPosyanduDate': nextPosyanduDate == null
        ? null
        : dateToIso(nextPosyanduDate!),
    'landingSeen': landingSeen,
    'readArticles': readArticles.toList(),
    'mealPlan': mealPlan,
    'remindersEnabled': remindersEnabled,
  };

  factory AppState.fromJson(Map<String, dynamic> json) => AppState(
    users: (json['users'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    currentUserId: json['currentUserId'] as String?,
    children: (json['children'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Child.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    pregnancies: (json['pregnancies'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Pregnancy.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    foodLogs: (json['foodLogs'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => FoodLog.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    roster: (json['roster'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => RosterEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    sessions: (json['sessions'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => PosyanduSession.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    contents: (json['contents'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => ContentArticle.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    accessGrants: (json['accessGrants'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AccessGrant.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    selectedChildId: json['selectedChildId'] as String?,
    onboardingSeen: json['onboardingSeen'] as bool? ?? false,
    consentAccepted: json['consentAccepted'] as bool? ?? false,
    consentVersion: json['consentVersion'] as String? ?? '2026-11',
    pregnancyContext: json['pregnancyContext'] as bool? ?? true,
    pendingWrites: parseInt(json['pendingWrites']) ?? 0,
    lastSyncAt: parseDate(json['lastSyncAt']),
    posyanduName: json['posyanduName'] as String? ?? 'Posyandu Melati II',
    posyanduArea: json['posyanduArea'] as String? ?? 'Kelurahan Sukamaju',
    nextPosyanduDate: parseDate(json['nextPosyanduDate']),
    landingSeen: json['landingSeen'] as bool? ?? false,
    readArticles: _stringList(json['readArticles']).toSet(),
    mealPlan: _stringList(json['mealPlan']),
    remindersEnabled: json['remindersEnabled'] as bool? ?? true,
  );
}

const Object _unset = Object();

/// Pembulatan tampilan. Perhitungan tetap memakai nilai penuh.
String fmt1(double? value) => value == null ? '—' : value.toStringAsFixed(1);
String fmt2(double? value) => value == null ? '—' : value.toStringAsFixed(2);
String fmt0(double? value) => value == null ? '—' : value.round().toString();

double clampDouble(double value, double min, double max) =>
    math.min(math.max(value, min), max);
