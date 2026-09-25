import '../models/food_entry.dart';

/// Representasi item makanan dari database TKPI (Tabel Komposisi Pangan Indonesia)
/// Data per 100 gram bahan makanan
class FoodItem {
  final String id;
  final String name;
  final String category;
  final String defaultUnit; // gram, butir, porsi, sendok makan
  final double defaultPortion; // gram ekuivalen untuk 1 unit default
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultUnit,
    required this.defaultPortion,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });

  /// Relasi ke tabel kategori referensi.
  String get categoryId => FoodDatabase.categoryIdForName(category);

  FoodEntry toEntry({
    required String entryId,
    required String userId,
    required String dateKey,
    required String session,
    required double gram,
    String? childId,
  }) {
    final factor = gram / 100;
    return FoodEntry(
      id: entryId,
      userId: userId,
      foodItemId: id,
      foodName: name,
      categoryId: categoryId,
      childId: childId,
      dateKey: dateKey,
      session: session,
      portionGram: gram,
      calories: caloriesPer100g * factor,
      protein: proteinPer100g * factor,
      carbs: carbsPer100g * factor,
      fat: fatPer100g * factor,
      addedAt: DateTime.now(),
      unit: defaultUnit,
    );
  }
}

/// Database makanan sederhana berbasis TKPI Kemenkes RI
/// Data per 100 gram
class FoodDatabase {
  static const List<FoodItem> items = [
    // === KARBOHIDRAT ===
    FoodItem(
      id: 'nasi_putih',
      name: 'Nasi Putih',
      category: 'Karbohidrat',
      defaultUnit: 'porsi',
      defaultPortion: 150,
      caloriesPer100g: 130,
      proteinPer100g: 2.4,
      carbsPer100g: 28.6,
      fatPer100g: 0.1,
    ),
    FoodItem(
      id: 'nasi_merah',
      name: 'Nasi Merah',
      category: 'Karbohidrat',
      defaultUnit: 'porsi',
      defaultPortion: 150,
      caloriesPer100g: 111,
      proteinPer100g: 2.6,
      carbsPer100g: 23.5,
      fatPer100g: 0.9,
    ),
    FoodItem(
      id: 'roti_gandum',
      name: 'Roti Gandum',
      category: 'Karbohidrat',
      defaultUnit: 'lembar',
      defaultPortion: 30,
      caloriesPer100g: 247,
      proteinPer100g: 8.4,
      carbsPer100g: 48.3,
      fatPer100g: 3.2,
    ),
    FoodItem(
      id: 'ubi_jalar',
      name: 'Ubi Jalar',
      category: 'Karbohidrat',
      defaultUnit: 'buah sedang',
      defaultPortion: 100,
      caloriesPer100g: 86,
      proteinPer100g: 1.6,
      carbsPer100g: 20.1,
      fatPer100g: 0.1,
    ),
    FoodItem(
      id: 'singkong',
      name: 'Singkong',
      category: 'Karbohidrat',
      defaultUnit: 'potong',
      defaultPortion: 80,
      caloriesPer100g: 154,
      proteinPer100g: 1.2,
      carbsPer100g: 36.8,
      fatPer100g: 0.3,
    ),

    // === PROTEIN HEWANI ===
    FoodItem(
      id: 'ayam_goreng',
      name: 'Ayam Goreng',
      category: 'Protein Hewani',
      defaultUnit: 'potong',
      defaultPortion: 80,
      caloriesPer100g: 298,
      proteinPer100g: 24.8,
      carbsPer100g: 3.0,
      fatPer100g: 20.2,
    ),
    FoodItem(
      id: 'ikan_goreng',
      name: 'Ikan Goreng',
      category: 'Protein Hewani',
      defaultUnit: 'potong',
      defaultPortion: 60,
      caloriesPer100g: 253,
      proteinPer100g: 26.0,
      carbsPer100g: 0.0,
      fatPer100g: 16.0,
    ),
    FoodItem(
      id: 'telur_ayam',
      name: 'Telur Ayam',
      category: 'Protein Hewani',
      defaultUnit: 'butir',
      defaultPortion: 55,
      caloriesPer100g: 154,
      proteinPer100g: 12.4,
      carbsPer100g: 0.7,
      fatPer100g: 10.8,
    ),
    FoodItem(
      id: 'daging_sapi',
      name: 'Daging Sapi',
      category: 'Protein Hewani',
      defaultUnit: 'porsi',
      defaultPortion: 80,
      caloriesPer100g: 207,
      proteinPer100g: 18.8,
      carbsPer100g: 0.0,
      fatPer100g: 14.0,
    ),
    FoodItem(
      id: 'udang',
      name: 'Udang',
      category: 'Protein Hewani',
      defaultUnit: 'porsi',
      defaultPortion: 80,
      caloriesPer100g: 91,
      proteinPer100g: 21.0,
      carbsPer100g: 0.0,
      fatPer100g: 0.8,
    ),

    // === PROTEIN NABATI ===
    FoodItem(
      id: 'tahu',
      name: 'Tahu',
      category: 'Protein Nabati',
      defaultUnit: 'potong',
      defaultPortion: 80,
      caloriesPer100g: 68,
      proteinPer100g: 7.8,
      carbsPer100g: 1.6,
      fatPer100g: 4.6,
    ),
    FoodItem(
      id: 'tempe',
      name: 'Tempe',
      category: 'Protein Nabati',
      defaultUnit: 'potong',
      defaultPortion: 50,
      caloriesPer100g: 201,
      proteinPer100g: 20.8,
      carbsPer100g: 13.5,
      fatPer100g: 8.8,
    ),
    FoodItem(
      id: 'kacang_merah',
      name: 'Kacang Merah',
      category: 'Protein Nabati',
      defaultUnit: 'sendok makan',
      defaultPortion: 20,
      caloriesPer100g: 336,
      proteinPer100g: 22.1,
      carbsPer100g: 58.5,
      fatPer100g: 1.7,
    ),

    // === SAYURAN ===
    FoodItem(
      id: 'bayam',
      name: 'Bayam',
      category: 'Sayuran',
      defaultUnit: 'porsi',
      defaultPortion: 100,
      caloriesPer100g: 36,
      proteinPer100g: 3.5,
      carbsPer100g: 4.5,
      fatPer100g: 0.5,
    ),
    FoodItem(
      id: 'kangkung',
      name: 'Kangkung',
      category: 'Sayuran',
      defaultUnit: 'porsi',
      defaultPortion: 100,
      caloriesPer100g: 29,
      proteinPer100g: 3.0,
      carbsPer100g: 5.4,
      fatPer100g: 0.3,
    ),
    FoodItem(
      id: 'brokoli',
      name: 'Brokoli',
      category: 'Sayuran',
      defaultUnit: 'porsi',
      defaultPortion: 100,
      caloriesPer100g: 34,
      proteinPer100g: 2.8,
      carbsPer100g: 6.6,
      fatPer100g: 0.4,
    ),
    FoodItem(
      id: 'wortel',
      name: 'Wortel',
      category: 'Sayuran',
      defaultUnit: 'buah sedang',
      defaultPortion: 80,
      caloriesPer100g: 42,
      proteinPer100g: 1.0,
      carbsPer100g: 9.6,
      fatPer100g: 0.2,
    ),

    // === BUAH ===
    FoodItem(
      id: 'pisang',
      name: 'Pisang',
      category: 'Buah',
      defaultUnit: 'buah',
      defaultPortion: 100,
      caloriesPer100g: 90,
      proteinPer100g: 1.2,
      carbsPer100g: 23.4,
      fatPer100g: 0.2,
    ),
    FoodItem(
      id: 'pepaya',
      name: 'Pepaya',
      category: 'Buah',
      defaultUnit: 'potong',
      defaultPortion: 150,
      caloriesPer100g: 46,
      proteinPer100g: 0.5,
      carbsPer100g: 12.2,
      fatPer100g: 0.0,
    ),
    FoodItem(
      id: 'apel',
      name: 'Apel',
      category: 'Buah',
      defaultUnit: 'buah',
      defaultPortion: 120,
      caloriesPer100g: 58,
      proteinPer100g: 0.3,
      carbsPer100g: 14.9,
      fatPer100g: 0.4,
    ),
    FoodItem(
      id: 'jeruk',
      name: 'Jeruk',
      category: 'Buah',
      defaultUnit: 'buah',
      defaultPortion: 100,
      caloriesPer100g: 47,
      proteinPer100g: 0.9,
      carbsPer100g: 11.8,
      fatPer100g: 0.1,
    ),

    // === SUSU & OLAHAN ===
    FoodItem(
      id: 'susu_sapi',
      name: 'Susu Sapi',
      category: 'Susu & Olahan',
      defaultUnit: 'gelas',
      defaultPortion: 200,
      caloriesPer100g: 61,
      proteinPer100g: 3.2,
      carbsPer100g: 4.8,
      fatPer100g: 3.5,
    ),
    FoodItem(
      id: 'keju',
      name: 'Keju',
      category: 'Susu & Olahan',
      defaultUnit: 'lembar',
      defaultPortion: 20,
      caloriesPer100g: 326,
      proteinPer100g: 22.8,
      carbsPer100g: 2.1,
      fatPer100g: 25.9,
    ),
    FoodItem(
      id: 'yogurt',
      name: 'Yogurt',
      category: 'Susu & Olahan',
      defaultUnit: 'cup',
      defaultPortion: 150,
      caloriesPer100g: 59,
      proteinPer100g: 3.5,
      carbsPer100g: 7.0,
      fatPer100g: 1.5,
    ),

    // === MINUMAN ===
    FoodItem(
      id: 'jus_jeruk',
      name: 'Jus Jeruk',
      category: 'Minuman',
      defaultUnit: 'gelas',
      defaultPortion: 200,
      caloriesPer100g: 45,
      proteinPer100g: 0.7,
      carbsPer100g: 10.4,
      fatPer100g: 0.2,
    ),
  ];

  // Tabel referensi kategori (7 kategori sesuai SSGI/TKPI).
  static const Map<String, String> categoryIds = {
    'Karbohidrat': 'cat_karbohidrat',
    'Protein Hewani': 'cat_protein_hewani',
    'Protein Nabati': 'cat_protein_nabati',
    'Sayuran': 'cat_sayuran',
    'Buah': 'cat_buah',
    'Susu & Olahan': 'cat_susu_olahan',
    'Minuman': 'cat_minuman',
  };

  static const Map<String, String> categoryNames = {
    'cat_karbohidrat': 'Karbohidrat',
    'cat_protein_hewani': 'Protein Hewani',
    'cat_protein_nabati': 'Protein Nabati',
    'cat_sayuran': 'Sayuran',
    'cat_buah': 'Buah',
    'cat_susu_olahan': 'Susu & Olahan',
    'cat_minuman': 'Minuman',
  };

  static String categoryIdForName(String name) =>
      categoryIds[name] ?? 'cat_lainnya';

  static String categoryNameForId(String id) => categoryNames[id] ?? 'Lainnya';

  static List<FoodItem> search(String query) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  static List<FoodItem> byCategory(String category) {
    return items.where((f) => f.category == category).toList();
  }

  static List<FoodItem> byCategoryId(String categoryId) {
    return items.where((f) => f.categoryId == categoryId).toList();
  }

  static List<String> get categories {
    return items.map((f) => f.category).toSet().toList();
  }

  static FoodItem? findById(String id) {
    try {
      return items.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
