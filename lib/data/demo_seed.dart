import '../domain/growth/growth_calculator.dart';
import '../domain/growth/who_lms.dart';
import '../domain/models.dart';
import '../domain/pregnancy/pregnancy_calculator.dart';

/// Data demo sintetis dan berlabel. Tidak ada data pasien nyata.
/// Tanggal dibuat relatif terhadap hari pertama aplikasi dijalankan agar
/// demo selalu terasa "hari ini", tanpa mengubah data setelah tersimpan.
class DemoSeed {
  const DemoSeed._();

  static AppState build({required WhoReference who, DateTime? today}) {
    final now = dateOnly(today ?? DateTime.now());
    final calculator = GrowthCalculator(reference: who);

    Measurement measure(
      Child child, {
      required double weightKg,
      required double heightCm,
      required DateTime date,
      required String source,
      String? sessionId,
      MeasurementMethod? method,
      bool synced = true,
    }) {
      final ageMonths = child.ageMonthsAt(date);
      final eval = calculator.evaluate(
        heightCm: heightCm,
        weightKg: weightKg,
        sex: child.sex,
        dob: child.dob,
        measureDate: date,
        method: method ?? GrowthCalculator.defaultMethodForAge(ageMonths),
        allowImplausible: true,
      );
      return Measurement(
        id: 'm_${child.id}_${dateToIso(date)}',
        date: date,
        ageDays: eval.ageDays,
        ageMonths: eval.ageMonths,
        weightKg: weightKg,
        measuredCm: heightCm,
        method: eval.method,
        correctedCm: eval.correctedCm,
        zHfa: eval.zScore,
        category: eval.category,
        source: source,
        recordedByUid: source == 'kader' ? 'u_kader' : 'u_ibu',
        sessionId: sessionId,
        flags: eval.flags,
        synced: synced,
        createdAt: date,
      );
    }

    final rafiDob = now.subtract(const Duration(days: 548));
    final rafi = Child(
      id: 'c_rafi',
      nickname: 'Rafi Ahmad',
      dob: rafiDob,
      sex: Sex.male,
      guardianName: 'Siti Rahma',
      guardianUid: 'u_ibu',
      posyanduId: 'p_melati',
      birthWeightKg: 3.1,
      birthLengthCm: 49,
      linked: true,
      avatarIndex: 0,
      measurements: [
        measure(
          Child(
            id: 'c_rafi',
            nickname: 'Rafi Ahmad',
            dob: rafiDob,
            sex: Sex.male,
            guardianName: 'Siti Rahma',
          ),
          weightKg: 8.8,
          heightCm: 75.0,
          date: rafiDob.add(const Duration(days: 365)),
          source: 'kader',
        ),
        measure(
          Child(
            id: 'c_rafi',
            nickname: 'Rafi Ahmad',
            dob: rafiDob,
            sex: Sex.male,
            guardianName: 'Siti Rahma',
          ),
          weightKg: 10.1,
          heightCm: 78.5,
          date: rafiDob.add(const Duration(days: 456)),
          source: 'mandiri',
        ),
        measure(
          Child(
            id: 'c_rafi',
            nickname: 'Rafi Ahmad',
            dob: rafiDob,
            sex: Sex.male,
            guardianName: 'Siti Rahma',
          ),
          weightKg: 11.2,
          heightCm: 82.5,
          date: rafiDob.add(const Duration(days: 548)),
          source: 'kader',
          sessionId: 's_maret',
        ),
      ],
    );

    final kenzoDob = now.subtract(const Duration(days: 427));
    final kenzo = Child(
      id: 'c_kenzo',
      nickname: 'Kenzo Al-Ghifari',
      dob: kenzoDob,
      sex: Sex.male,
      guardianName: 'Dewi Lestari',
      posyanduId: 'p_melati',
      linked: false,
      avatarIndex: 1,
      measurements: [
        measure(
          Child(
            id: 'c_kenzo',
            nickname: 'Kenzo Al-Ghifari',
            dob: kenzoDob,
            sex: Sex.male,
            guardianName: 'Dewi Lestari',
          ),
          weightKg: 8.8,
          heightCm: 72.0,
          date: kenzoDob.add(const Duration(days: 365)),
          source: 'kader',
        ),
        measure(
          Child(
            id: 'c_kenzo',
            nickname: 'Kenzo Al-Ghifari',
            dob: kenzoDob,
            sex: Sex.male,
            guardianName: 'Dewi Lestari',
          ),
          weightKg: 8.95,
          heightCm: 72.8,
          date: kenzoDob.add(const Duration(days: 426)),
          source: 'kader',
          sessionId: 's_maret',
          synced: false,
        ),
      ],
    );

    final mayaDob = now.subtract(const Duration(days: 670));
    final maya = Child(
      id: 'c_maya',
      nickname: 'Maya Clarissa',
      dob: mayaDob,
      sex: Sex.female,
      guardianName: 'Sinta',
      posyanduId: 'p_melati',
      linked: true,
      guardianUid: 'u_maya',
      avatarIndex: 2,
      measurements: [
        measure(
          Child(
            id: 'c_maya',
            nickname: 'Maya Clarissa',
            dob: mayaDob,
            sex: Sex.female,
            guardianName: 'Sinta',
          ),
          weightKg: 10.5,
          heightCm: 76.0,
          date: now.subtract(const Duration(days: 10)),
          source: 'kader',
          sessionId: 's_maret',
        ),
      ],
    );

    final aisyahDob = now.subtract(const Duration(days: 1096));
    final bimaDob = now.subtract(const Duration(days: 914));
    final nadiaDob = now.subtract(const Duration(days: 244));
    final adnanDob = now.subtract(const Duration(days: 244));
    final aisyah = Child(
      id: 'c_aisyah',
      nickname: 'Aisyah Putri',
      dob: aisyahDob,
      sex: Sex.female,
      guardianName: 'Rina',
      posyanduId: 'p_melati',
      linked: false,
      avatarIndex: 3,
      measurements: [
        measure(
          Child(
            id: 'c_aisyah',
            nickname: 'Aisyah Putri',
            dob: aisyahDob,
            sex: Sex.female,
            guardianName: 'Rina',
          ),
          weightKg: 13.2,
          heightCm: 90.0,
          date: now.subtract(const Duration(days: 2)),
          source: 'kader',
          sessionId: 's_maret',
        ),
      ],
    );
    final bima = Child(
      id: 'c_bima',
      nickname: 'Bima Saputra',
      dob: bimaDob,
      sex: Sex.male,
      guardianName: 'Yuni',
      posyanduId: 'p_melati',
      linked: false,
      avatarIndex: 4,
      measurements: [
        measure(
          Child(
            id: 'c_bima',
            nickname: 'Bima Saputra',
            dob: bimaDob,
            sex: Sex.male,
            guardianName: 'Yuni',
          ),
          weightKg: 12.2,
          heightCm: 86.0,
          date: now.subtract(const Duration(days: 2)),
          source: 'kader',
          sessionId: 's_maret',
        ),
      ],
    );
    final nadia = Child(
      id: 'c_nadia',
      nickname: 'Nadia Putri',
      dob: nadiaDob,
      sex: Sex.female,
      guardianName: 'Lia',
      posyanduId: 'p_melati',
      linked: false,
      avatarIndex: 5,
      measurements: [
        measure(
          Child(
            id: 'c_nadia',
            nickname: 'Nadia Putri',
            dob: nadiaDob,
            sex: Sex.female,
            guardianName: 'Lia',
          ),
          weightKg: 7.2,
          heightCm: 64.0,
          date: now.subtract(const Duration(days: 1)),
          source: 'kader',
          sessionId: 's_maret',
        ),
      ],
    );
    final adnan = Child(
      id: 'c_adnan',
      nickname: 'Adnan Putra',
      dob: adnanDob,
      sex: Sex.male,
      guardianName: 'Ibu Ratna',
      posyanduId: 'p_melati',
      linked: false,
      avatarIndex: 6,
      measurements: [],
    );

    // 31 balita tambahan agar rekap sesi 52 sasaran konsisten dengan
    // distribusi 31 normal / 5 pendek / 2 sangat pendek pada 38 balita.
    const extraNames = [
      'Alif Pratama',
      'Zahra Amelia',
      'Fikri Ramadhan',
      'Naura Safira',
      'Raka Aditya',
      'Alesha Putri',
      'Daffa Maulana',
      'Khansa Humaira',
      'Arsenio Bagas',
      'Salsabila Rahma',
      'Elvano Putra',
      'Keisha Anindya',
      'Gibran Alfarizi',
      'Talita Zahra',
      'Rayyan Hafiz',
      'Alika Meidina',
      'Farhan Nugroho',
      'Shanum Aqila',
      'Kevin Pratama',
      'Mahira Azzahra',
      'Yoga Saputra',
      'Callista Dewi',
      'Rizky Maulana',
      'Aqila Nabila',
      'Bintang Ramadhan',
      'Larasati Putri',
      'Fauzan Akbar',
      'Amirah Zahira',
      'Dimas Arya',
      'Nayla Safitri',
      'Haris Setiawan',
    ];
    const extraGuardians = [
      'Ibu Wulan',
      'Ibu Rina',
      'Ibu Fitri',
      'Ibu Yuni',
      'Ibu Desi',
      'Ibu Endang',
      'Ibu Sri',
      'Ibu Novita',
      'Ibu Lestari',
      'Ibu Hartini',
      'Ibu Murni',
      'Ibu Ratih',
      'Ibu Sari',
      'Ibu Dian',
    ];
    const extraAges = [
      3,
      5,
      7,
      9,
      11,
      13,
      15,
      17,
      19,
      21,
      23,
      25,
      27,
      29,
      31,
      33,
      35,
      37,
      39,
      41,
      43,
      45,
      47,
      49,
      51,
      53,
      4,
      8,
      12,
      16,
      20,
    ];
    const extraCategories = <GrowthCategory>[
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.stunted,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.stunted,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.stunted,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.severelyStunted,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.stunted,
      GrowthCategory.normal,
      GrowthCategory.normal,
      GrowthCategory.normal,
    ];
    const waitingExtraIndexes = {5, 11, 17, 23, 29};

    final extraChildren = <Child>[];
    for (var i = 0; i < extraNames.length; i++) {
      final sex = i.isEven ? Sex.male : Sex.female;
      final months = extraAges[i];
      final dob = now.subtract(Duration(days: (months * 30.4375).round() + 1));
      final base = Child(
        id: 'c_extra_$i',
        nickname: extraNames[i],
        dob: dob,
        sex: sex,
        guardianName: extraGuardians[i % extraGuardians.length],
        posyanduId: 'p_melati',
        linked: false,
        avatarIndex: (i + 7) % 8,
      );
      final ageDays = base.ageDaysAt(now);
      final targetZ = switch (extraCategories[i]) {
        GrowthCategory.stunted => -2.45,
        GrowthCategory.severelyStunted => -3.15,
        GrowthCategory.tall => 2.2,
        GrowthCategory.normal => 0.2,
      };
      final height = who.forSex(sex).valueAtZ(ageDays.toDouble(), targetZ);
      final weight = (3.0 + months * 0.28).clamp(2.5, 25.0).toDouble();
      extraChildren.add(
        base.copyWith(
          measurements: [
            measure(
              base,
              weightKg: weight,
              heightCm: height,
              date: now.subtract(Duration(days: 3 + (i % 9))),
              source: 'kader',
              sessionId: 's_maret',
            ),
          ],
        ),
      );
    }

    final hpht = now.subtract(const Duration(days: 171));
    final hpl = PregnancyCalculator.hplFromHpht(hpht);
    final pregnancy = Pregnancy(
      id: 'preg_siti',
      ownerUid: 'u_ibu',
      hpht: hpht,
      hpl: hpl,
      status: PregnancyStatus.active,
      checkups: [
        Checkup(
          id: 'chk_1',
          date: now.subtract(const Duration(days: 70)),
          weightKg: 54.2,
          lilaCm: 24.8,
          hbGdl: 12.1,
          systolic: 110,
          diastolic: 70,
          source: 'kader',
          recordedBy: 'Bd. Nurul',
        ),
        Checkup(
          id: 'chk_2',
          date: now.subtract(const Duration(days: 38)),
          weightKg: 56.8,
          lilaCm: 24.6,
          hbGdl: 11.9,
          systolic: 112,
          diastolic: 72,
          source: 'kader',
          recordedBy: 'Bd. Nurul',
        ),
        Checkup(
          id: 'chk_3',
          date: now.subtract(const Duration(days: 10)),
          weightKg: 58.5,
          lilaCm: 24.5,
          hbGdl: 11.8,
          systolic: 115,
          diastolic: 75,
          source: 'kader',
          recordedBy: 'Bd. Nurul',
        ),
      ],
      ttdDates: List.generate(
        48,
        (i) => dateToIso(now.subtract(Duration(days: i))),
      ),
      ancVisits: [
        AncVisit(
          id: 'anc_1',
          date: now.subtract(const Duration(days: 130)),
          facility: 'Puskesmas Kebayoran',
        ),
        AncVisit(
          id: 'anc_2',
          date: now.subtract(const Duration(days: 100)),
          facility: 'Puskesmas Kebayoran',
        ),
        AncVisit(
          id: 'anc_3',
          date: now.subtract(const Duration(days: 60)),
          facility: 'Bidan Desa Nurul',
        ),
        AncVisit(
          id: 'anc_4',
          date: now.subtract(const Duration(days: 10)),
          facility: 'Bidan Desa Nurul',
        ),
      ],
      createdAt: hpht,
    );

    final foodLogs = <FoodLog>[
      FoodLog(
        id: 'fl_rafi_breakfast',
        subjectId: 'c_rafi',
        date: now,
        meal: MealType.breakfast,
        items: [
          FoodLogItem(
            foodId: 'demo_bubur_hati',
            name: 'Bubur beras hati ayam',
            grams: 150,
            kcalPer100: 250,
            proteinPer100: 7.7,
            fatPer100: 5.0,
            carbPer100: 44.0,
            ironPer100: 2.0,
            zincPer100: 1.5,
            source: FoodSource.recipe,
          ),
        ],
        note: 'Porsi 150 gram (habis)',
        createdAt: now,
      ),
      FoodLog(
        id: 'fl_rafi_lunch',
        subjectId: 'c_rafi',
        date: now,
        meal: MealType.lunch,
        items: [
          FoodLogItem(
            foodId: 'demo_nasi_tim_ikan',
            name: 'Nasi tim ikan kembung & sayur',
            grams: 150,
            kcalPer100: 206.7,
            proteinPer100: 11.2,
            fatPer100: 5.8,
            carbPer100: 27.0,
            ironPer100: 1.6,
            zincPer100: 1.2,
            source: FoodSource.ai,
            confidence: 0.94,
          ),
        ],
        note: 'Brokoli, wortel, telur rebus',
        createdAt: now,
      ),
      FoodLog(
        id: 'fl_siti_breakfast',
        subjectId: 'preg_siti',
        date: now,
        meal: MealType.breakfast,
        items: [
          FoodLogItem(
            foodId: 'demo_oatmeal',
            name: 'Oatmeal pisang & susu',
            grams: 220,
            kcalPer100: 113,
            proteinPer100: 4.2,
            fatPer100: 3.1,
            carbPer100: 17.5,
            ironPer100: 0.7,
            zincPer100: 0.5,
            source: FoodSource.recipe,
          ),
        ],
        createdAt: now,
      ),
      FoodLog(
        id: 'fl_siti_lunch',
        subjectId: 'preg_siti',
        date: now,
        meal: MealType.lunch,
        items: [
          FoodLogItem(
            foodId: 'demo_nasi_ayam',
            name: 'Nasi, ayam bumbu kuning, sayur',
            grams: 280,
            kcalPer100: 160,
            proteinPer100: 7.5,
            fatPer100: 5.0,
            carbPer100: 20.0,
            ironPer100: 1.1,
            zincPer100: 0.8,
            source: FoodSource.manual,
          ),
        ],
        createdAt: now,
      ),
      FoodLog(
        id: 'fl_rafi_yesterday_breakfast',
        subjectId: 'c_rafi',
        date: now.subtract(const Duration(days: 1)),
        meal: MealType.breakfast,
        items: [
          FoodLogItem(
            foodId: 'demo_bubur_hati',
            name: 'Bubur beras hati ayam',
            grams: 150,
            kcalPer100: 250,
            proteinPer100: 7.7,
            fatPer100: 5.0,
            carbPer100: 44.0,
            ironPer100: 2.0,
            zincPer100: 1.5,
            source: FoodSource.recipe,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    final roster = <RosterEntry>[
      RosterEntry(
        id: 'r_kenzo',
        name: 'Kenzo Al-Ghifari',
        type: RosterType.child,
        attendance: AttendanceStatus.absent,
        avatarIndex: 1,
        subjectId: 'c_kenzo',
        guardianName: 'Ibu Dewi Lestari • RT 02 / RW 04',
        ageMonths: 14,
        sex: Sex.male,
        category: GrowthCategory.stunted,
        priority: true,
        reason: 'BB Tidak Naik 2x (T2) • LILA Kurang',
        followUpStatus: FollowUpStatus.open,
        linked: false,
        lastMeasuredAt: now.subtract(const Duration(days: 30)),
        pendingSync: true,
      ),
      RosterEntry(
        id: 'r_rafi',
        name: 'Rafi Ahmad',
        type: RosterType.child,
        attendance: AttendanceStatus.present,
        avatarIndex: 0,
        subjectId: 'c_rafi',
        guardianName: 'Ibu Siti Rahma • RT 03 / RW 04',
        ageMonths: 18,
        sex: Sex.male,
        category: GrowthCategory.normal,
        linked: true,
        lastMeasuredAt: now,
        followUpStatus: FollowUpStatus.closed,
      ),
      RosterEntry(
        id: 'r_maya',
        name: 'Maya Clarissa',
        type: RosterType.child,
        attendance: AttendanceStatus.waiting,
        avatarIndex: 2,
        subjectId: 'c_maya',
        guardianName: 'Ibu Sinta • RT 05 / RW 04',
        ageMonths: 22,
        sex: Sex.female,
        category: GrowthCategory.severelyStunted,
        priority: true,
        reason: 'Indikasi Sangat Pendek (Perlu Konfirmasi PB)',
        followUpStatus: FollowUpStatus.referred,
        linked: true,
        lastMeasuredAt: now.subtract(const Duration(days: 10)),
      ),
      RosterEntry(
        id: 'r_anisa',
        name: 'Ibu Anisa Wardani',
        type: RosterType.pregnant,
        attendance: AttendanceStatus.present,
        avatarIndex: 7,
        guardianName: 'Bumil KEK • RT 04 / RW 04',
        pregnancyWeeks: 26,
        priority: true,
        reason: 'LiLA 22,5 cm (< 23,5 cm Risiko KEK)',
        followUpStatus: FollowUpStatus.open,
        lilaCm: 22.5,
        hbGdl: 10.8,
        lastMeasuredAt: now,
      ),
      RosterEntry(
        id: 'r_adnan',
        name: 'Adnan Putra',
        type: RosterType.child,
        attendance: AttendanceStatus.absent,
        avatarIndex: 6,
        subjectId: 'c_adnan',
        guardianName: 'Ibu Ratna • RT 01 / RW 04',
        ageMonths: 8,
        sex: Sex.male,
        category: GrowthCategory.normal,
        reason: 'Tidak hadir 2 sesi berturut-turut',
        followUpStatus: FollowUpStatus.open,
        linked: false,
      ),
      RosterEntry(
        id: 'r_aisyah',
        name: 'Aisyah Putri',
        type: RosterType.child,
        attendance: AttendanceStatus.present,
        avatarIndex: 3,
        subjectId: 'c_aisyah',
        guardianName: 'Ibu Rina • RT 02 / RW 04',
        ageMonths: 36,
        sex: Sex.female,
        category: GrowthCategory.normal,
        linked: false,
        lastMeasuredAt: now.subtract(const Duration(days: 2)),
        followUpStatus: FollowUpStatus.closed,
      ),
      RosterEntry(
        id: 'r_bima',
        name: 'Bima Saputra',
        type: RosterType.child,
        attendance: AttendanceStatus.present,
        avatarIndex: 4,
        subjectId: 'c_bima',
        guardianName: 'Ibu Yuni • RT 03 / RW 04',
        ageMonths: 30,
        sex: Sex.male,
        category: GrowthCategory.normal,
        linked: false,
        lastMeasuredAt: now.subtract(const Duration(days: 2)),
        followUpStatus: FollowUpStatus.closed,
      ),
      RosterEntry(
        id: 'r_nadia',
        name: 'Nadia Putri',
        type: RosterType.child,
        attendance: AttendanceStatus.present,
        avatarIndex: 5,
        subjectId: 'c_nadia',
        guardianName: 'Ibu Lia • RT 05 / RW 04',
        ageMonths: 8,
        sex: Sex.female,
        category: GrowthCategory.normal,
        linked: false,
        lastMeasuredAt: now.subtract(const Duration(days: 1)),
        followUpStatus: FollowUpStatus.closed,
      ),
    ];

    for (var i = 0; i < extraChildren.length; i++) {
      final child = extraChildren[i];
      final latest = child.latestMeasurement;
      final category = latest?.category ?? GrowthCategory.normal;
      roster.add(
        RosterEntry(
          id: 'r_extra_$i',
          name: child.nickname,
          type: RosterType.child,
          attendance: waitingExtraIndexes.contains(i)
              ? AttendanceStatus.waiting
              : AttendanceStatus.present,
          avatarIndex: child.avatarIndex,
          subjectId: child.id,
          guardianName: '${child.guardianName} • RT 0${(i % 6) + 1} / RW 04',
          ageMonths: child.ageMonthsAt(now),
          sex: child.sex,
          category: category,
          priority: false,
          reason: category.needsFollowUp
              ? 'Hasil skrining ${category.label}'
              : null,
          followUpStatus: FollowUpStatus.closed,
          linked: false,
          lastMeasuredAt: latest?.date,
          sessionId: 's_maret',
        ),
      );
    }

    const extraPregnantNames = [
      'Ibu Rina Marlina',
      'Ibu Fitri Handayani',
      'Ibu Yuliana',
      'Ibu Desi Ratnasari',
      'Ibu Endang Susanti',
      'Ibu Sri Wahyuni',
      'Ibu Novita Sari',
      'Ibu Lestari',
      'Ibu Hartini',
      'Ibu Murni',
      'Ibu Ratih',
      'Ibu Sari Dewi',
      'Ibu Dian Permata',
    ];
    const extraWeeks = [12, 16, 20, 24, 28, 30, 32, 34, 18, 22, 26, 36, 14];
    for (var i = 0; i < extraPregnantNames.length; i++) {
      final risky = i == 1 || i == 5 || i == 9;
      final lila = risky ? 22.1 + (i * 0.1) : 24.0 + (i * 0.2);
      final hb = i == 3 ? 10.6 : 11.4 + (i % 4) * 0.2;
      roster.add(
        RosterEntry(
          id: 'r_bumil_$i',
          name: extraPregnantNames[i],
          type: RosterType.pregnant,
          attendance: i < 7
              ? AttendanceStatus.present
              : AttendanceStatus.waiting,
          avatarIndex: (i + 2) % 8,
          guardianName: 'Bumil • RT 0${(i % 5) + 1} / RW 04',
          pregnancyWeeks: extraWeeks[i],
          priority: risky,
          reason: risky
              ? 'LiLA ${lila.toStringAsFixed(1)} cm (< 23,5 cm Risiko KEK)'
              : null,
          followUpStatus: risky ? FollowUpStatus.open : FollowUpStatus.closed,
          lilaCm: lila,
          hbGdl: hb,
          lastMeasuredAt: risky ? now.subtract(const Duration(days: 14)) : null,
          sessionId: 's_maret',
        ),
      );
    }

    final contents = <ContentArticle>[
      ContentArticle(
        id: 'art_protein',
        title: 'Cegah Stunting: Mengapa Protein Hewani Sangat Penting di Usia 1–2 Tahun?',
        excerpt: 'Asam amino esensial lengkap pada telur, ikan, kembung, dan daging ayam mendukung pacu tumbuh sel tulang dan otot anak.',
        body:
            'Protein hewani menyediakan asam amino esensial yang lengkap. Pada masa 1–2 tahun, kebutuhan protein meningkat untuk mendukung pertumbuhan tulang, otot, dan perkembangan otak.\n\n'
            'Beberapa pilihan yang mudah ditemukan di sekitar rumah: telur, ikan kembung, ikan lele, ayam, dan hati ayam. Sajikan 2–3 kali sehari dalam porsi kecil yang sesuai usia dan tekstur anak.\n\n'
            'Protein hewani bukan pengganti makanan pokok, sayur, dan buah. Lengkapi piring anak dengan karbohidrat, sayur, dan buah. Bila anak sulit makan atau berat badannya tidak naik, diskusikan dengan kader atau tenaga kesehatan.\n\n'
            'Catatan: artikel ini adalah edukasi umum, bukan diagnosis. Keputusan pemberian makan dan tindak lanjut medis tetap bersama tenaga kesehatan.',
        category: 'Pencegahan Stunting',
        imageAsset: 'assets/images/article_food.jpg',
        readMinutes: 3,
        source: 'Kemenkes RI • Buku KIA',
        reviewedBy: 'Tim NURI',
        targetStatus: 'normal',
        ageMinMonths: 12,
        ageMaxMonths: 24,
        tags: ['protein hewani', 'MPASI', '1-2 tahun'],
      ),
      ContentArticle(
        id: 'art_trimester2',
        title: 'Panduan Aman Trimester 2',
        excerpt: 'Kenali tanda bahaya yang perlu segera ditindaklanjuti selama kehamilan trimester kedua.',
        body:
            'Trimester kedua sering terasa lebih nyaman, tetapi tetap perlu waspada. Perhatikan asupan makan, tablet tambah darah, dan jadwal pemeriksaan kehamilan.\n\n'
            'Segera hubungi bidan atau fasilitas kesehatan bila mengalami perdarahan, nyeri perut hebat, pusing berat, pandangan kabur, bengkak pada kaki dan wajah, atau gerakan janin berkurang.\n\n'
            'Catatan: panduan ini bersifat edukatif. Hubungi tenaga kesehatan untuk keluhan yang mengkhawatirkan.',
        category: 'Kehamilan',
        imageAsset: 'assets/images/hero_baby.jpg',
        readMinutes: 4,
        source: 'Kemenkes RI • Buku KIA',
        reviewedBy: 'Tim NURI',
        ageMinMonths: null,
        ageMaxMonths: null,
        tags: ['trimester 2', 'tanda bahaya'],
      ),
      ContentArticle(
        id: 'art_mpasi',
        title: 'MPASI 4 Bintang: Porsi dan Tekstur Sesuai Usia',
        excerpt: 'Karbohidrat, protein hewani, sayur, dan buah dalam satu piring. Ini cara menyusunnya.',
        body:
            'MPASI 4 bintang terdiri dari makanan pokok, protein hewani, sayur, dan buah. Variasi bahan membantu anak mengenal rasa dan tekstur.\n\n'
            'Usia 6–8 bulan: tekstur lumat, 2–3 sendok makan setiap kali makan. Usia 9–11 bulan: cincang halus, 3–4 sendok makan. Usia 12–23 bulan: cincang kasar, 4–5 sendok makan.\n\n'
            'Tambahkan sedikit minyak atau santan untuk energi. Hindari gula dan garam berlebih. Lanjutkan ASI sampai 2 tahun bila memungkinkan.',
        category: 'MPASI',
        imageAsset: 'assets/images/food_plate.jpg',
        readMinutes: 5,
        source: 'Kemenkes RI • Pedoman MPASI',
        reviewedBy: 'Tim NURI',
        targetStatus: 'normal',
        ageMinMonths: 6,
        ageMaxMonths: 24,
        tags: ['MPASI', '4 bintang'],
      ),
      ContentArticle(
        id: 'art_ttd',
        title: 'TTD Rutin, Cegah Anemia pada Ibu Hamil',
        excerpt: 'Tablet tambah darah diminum setiap hari. Simak cara minum yang nyaman untuk lambung.',
        body:
            'Tablet tambah darah (TTD) membantu memenuhi kebutuhan zat besi ibu hamil. Kekurangan zat besi dapat meningkatkan risiko anemia dan komplikasi kehamilan.\n\n'
            'Minum TTD setiap hari setelah makan, atau sebelum tidur bila mual. Hindari minum bersama teh atau kopi karena dapat menghambat penyerapan zat besi. Bila mengalami sembelit, minum air yang cukup dan makan buah serta sayur.\n\n'
            'Bila muncul keluhan yang mengganggu, konsultasikan dengan bidan atau dokter. Jangan menghentikan TTD tanpa saran tenaga kesehatan.',
        category: 'Kehamilan',
        imageAsset: 'assets/images/hero_family.jpg',
        readMinutes: 3,
        source: 'Kemenkes RI',
        reviewedBy: 'Tim NURI',
        tags: ['TTD', 'anemia'],
      ),
      ContentArticle(
        id: 'art_1000hpk',
        title: '1000 Hari Pertama Kehidupan',
        excerpt: 'Dari kehamilan sampai usia 2 tahun: masa paling menentukan untuk tumbuh kembang anak.',
        body:
            '1000 hari pertama kehidupan dihitung sejak masa kehamilan sampai anak berusia 2 tahun. Pada masa ini, pertumbuhan otak dan tubuh berlangsung sangat cepat.\n\n'
            'Gizi ibu saat hamil, ASI, MPASI yang bergizi, stimulasi, dan pemeriksaan rutin adalah fondasi yang saling melengkapi. Pencegahan stunting paling efektif dimulai sebelum dan saat kehamilan.\n\n'
            'NURI membantu memantau, bukan menggantikan pemeriksaan tenaga kesehatan.',
        category: '1000 HPK',
        imageAsset: 'assets/images/hero_baby.jpg',
        readMinutes: 4,
        source: 'Kemenkes RI',
        reviewedBy: 'Tim NURI',
        tags: ['1000 HPK', 'pencegahan stunting'],
      ),
    ];

    final users = [
      const AppUser(
        id: 'u_ibu',
        name: 'Siti Rahma',
        email: 'ibu@nuri.id',
        role: UserRole.mother,
        posyanduId: 'p_melati',
      ),
      const AppUser(
        id: 'u_kader',
        name: 'Nur Aisyah',
        email: 'kader@nuri.id',
        role: UserRole.cadre,
        posyanduId: 'p_melati',
        avatarAsset: 'assets/images/kader_avatar.jpg',
      ),
      const AppUser(
        id: 'u_maya',
        name: 'Sinta',
        email: 'sinta@nuri.id',
        role: UserRole.mother,
        posyanduId: 'p_melati',
      ),
    ];

    return AppState(
      users: users,
      currentUserId: null,
      children: [
        rafi,
        kenzo,
        maya,
        aisyah,
        bima,
        nadia,
        adnan,
        ...extraChildren,
      ],
      pregnancies: [pregnancy],
      foodLogs: foodLogs,
      roster: roster,
      sessions: [
        PosyanduSession(
          id: 's_maret',
          posyanduName: 'Posyandu Melati II',
          date: now,
          targetCount: 52,
          presentCount: 38,
          status: 'berlangsung',
          createdByUid: 'u_kader',
          note: 'Sesi penimbangan bulan ini',
        ),
      ],
      contents: contents,
      accessGrants: [
        AccessGrant(
          id: 'g_rafi_kader',
          ownerUid: 'u_ibu',
          granteeUid: 'u_kader',
          granteeName: 'Kader Bu Nur',
          subjectId: 'c_rafi',
          subjectName: 'Rafi Ahmad',
          posyanduId: 'p_melati',
          scopes: const ['ukur'],
          createdAt: now.subtract(const Duration(days: 20)),
          expiresAt: now.add(const Duration(days: 345)),
        ),
        AccessGrant(
          id: 'g_hamil_kader',
          ownerUid: 'u_ibu',
          granteeUid: 'u_kader',
          granteeName: 'Posyandu Melati II',
          subjectId: 'p_siti',
          subjectName: 'Kehamilan Siti Rahma',
          posyanduId: 'p_melati',
          scopes: const ['ukur'],
          createdAt: now.subtract(const Duration(days: 40)),
          expiresAt: now.add(const Duration(days: 325)),
        ),
      ],
      selectedChildId: 'c_rafi',
      onboardingSeen: true,
      consentAccepted: true,
      consentVersion: '2026-11',
      pregnancyContext: true,
      pendingWrites: 3,
      lastSyncAt: now.subtract(const Duration(days: 1)),
      posyanduName: 'Posyandu Melati II',
      posyanduArea: 'Kelurahan Sukamaju',
      nextPosyanduDate: now.add(const Duration(days: 27)),
      landingSeen: false,
      readArticles: const {'art_trimester2'},
      mealPlan: const ['menu_nasi_tim', 'menu_sup_bola', 'menu_opor_telur'],
      remindersEnabled: true,
    );
  }
}
