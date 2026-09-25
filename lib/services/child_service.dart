import '../models/child_profile.dart';

/// CRUD data anak dengan data simulasi dan relasi ownerUserId.
/// Data balita dari Ibu Balita bersifat privat; Kader melihat data wilayahnya.
class ChildService {
  static final ChildService _instance = ChildService._internal();
  factory ChildService() => _instance;
  ChildService._internal() {
    _seedDemoData();
  }

  final Map<String, ChildProfile> _children = {};
  int _idCounter = 0;

  List<ChildProfile> getChildren(String ownerUserId) {
    final result = _children.values
        .where((child) => child.ownerUserId == ownerUserId)
        .toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(result);
  }

  ChildProfile? findById(String id) => _children[id];

  String generateId(String ownerUserId) {
    _idCounter++;
    return 'child_${ownerUserId}_${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  void addChild(ChildProfile child) {
    if (child.id.isEmpty) {
      throw ArgumentError('ID anak tidak boleh kosong.');
    }
    if (child.ownerUserId.isEmpty) {
      throw ArgumentError('ID pemilik anak tidak boleh kosong.');
    }
    _children[child.id] = child;
  }

  void updateChild(ChildProfile child) {
    if (!_children.containsKey(child.id)) {
      throw StateError('Data anak tidak ditemukan.');
    }
    _children[child.id] = child;
  }

  void deleteChild(String id) {
    _children.remove(id);
  }

  void clear() => _children.clear();

  /// Mengembalikan data ke kondisi demo (untuk testing/demo ulang).
  void resetDemoData() {
    _children.clear();
    _seedDemoData();
  }

  void _seedDemoData() {
    final now = DateTime.now();
    void seed({
      required String id,
      required String owner,
      required String name,
      required int ageMonths,
      required double weight,
      required double height,
      required String mother,
      required String status,
      String gender = 'P',
      String notes = '',
    }) {
      addChild(
        ChildProfile(
          id: id,
          ownerUserId: owner,
          name: name,
          birthDate: DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: ageMonths * 30)),
          gender: gender,
          weightKg: weight,
          heightCm: height,
          motherName: mother,
          lastCheckDate: now.subtract(Duration(days: ageMonths % 30)),
          status: status,
          notes: notes,
        ),
      );
    }

    // Relasi anak utama untuk user demo Ibu Balita.
    seed(
      id: 'child_reyhan',
      owner: 'usr_01',
      name: 'Reyhan',
      ageMonths: 18,
      weight: 11.2,
      height: 82.4,
      mother: 'Diva Putri Adilla',
      status: 'Normal',
      gender: 'L',
      notes: 'Pertumbuhan sesuai kurva WHO.',
    );

    seed(
      id: 'child_salsabila',
      owner: 'usr_02',
      name: 'Salsabila',
      ageMonths: 14,
      weight: 9.8,
      height: 74.1,
      mother: 'Siti Rahmawati',
      status: 'Perlu Pemantauan',
      notes: 'PerluMCU rutin di Posyandu.',
    );

    // 20 record referensi untuk workflow Kader Posyandu (FR-04/FR-05).
    const kaderNames = [
      'Alya Putri',
      'Bimo Saputra',
      'Citra Lestari',
      'Daffa Pratama',
      'Elsa Maharani',
      'Fajar Nugroho',
      'Gita Anggraini',
      'Hafiz Maulana',
      'Intan Permata',
      'Joshua Kurniawan',
      'Kirana Balqis',
      'Lukman Hakim',
      'Maya Sari',
      'Naufal Akbar',
      'Olivia Ramdani',
      'Putra Wijaya',
      'Qonita Zahra',
      'Raka Abdullah',
      'Salsya Ramadhani',
      'Taufik Hidayat',
    ];
    const mothers = [
      'Ibu Rina',
      'Ibu Santi',
      'Ibu Wulan',
      'Ibu Yuni',
      'Ibu Ratna',
    ];
    const statuses = [
      'Normal',
      'Normal',
      'Perlu Pemantauan',
      'Normal',
      'Risiko Stunting',
    ];

    for (var i = 0; i < kaderNames.length; i++) {
      final age = 8 + (i * 2);
      final baseWeight = 7.0 + age * 0.32;
      final baseHeight = 66.0 + age * 1.15;
      final status = statuses[i % statuses.length];
      final adjustment = switch (status) {
        'Risiko Stunting' => -1.1,
        'Perlu Pemantauan' => -0.4,
        _ => 0.3,
      };
      seed(
        id: 'child_kader_${i + 1}',
        owner: 'usr_03',
        name: kaderNames[i],
        ageMonths: age,
        weight: double.parse((baseWeight + adjustment).toStringAsFixed(1)),
        height: double.parse((baseHeight + adjustment).toStringAsFixed(1)),
        mother: mothers[i % mothers.length],
        status: status,
        gender: i.isEven ? 'P' : 'L',
        notes: i % 4 == 0 ? 'Rujuk ke Puskesmas bila tidak sesuai kurva.' : '',
      );
    }
  }
}
