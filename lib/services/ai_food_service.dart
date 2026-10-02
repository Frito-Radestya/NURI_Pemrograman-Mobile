import 'dart:io';

import '../data/food_database.dart';

/// Satu hasil prediksi makanan dari model pretrained.
///
/// [label] adalah label mentah model (mis. "fried rice", "banana").
/// [confidence] 0.0 - 1.0.
/// [foodItemId] hasil mapping ke [FoodDatabase], null bila tidak dikenali.
class FoodPrediction {
  final String label;
  final double confidence;
  final String? foodItemId;

  const FoodPrediction({
    required this.label,
    required this.confidence,
    this.foodItemId,
  });

  FoodItem? get mappedFood => foodItemId == null
      ? null
      : FoodDatabase.findById(foodItemId!);

  bool get isLowConfidence => confidence < AiFoodService.confidenceThreshold;
}

/// Service klasifikasi makanan berbasis model pretrained.
///
/// Strategi (tanpa melatih model baru):
/// 1. Produksi: pakai model pretrained Food-101 (mis. EfficientNet-Lite0
///    / MobileNetV3 yang dilatih di Food-101, ±101 kelas, ±12MB TFLite)
///    atau ML Kit Image Labeling (pretrained Google, on-device).
/// 2. Mapping: label Inggris model -> [FoodDatabase] (TKPI, 25 item).
///    Makanan Indonesia yang tidak ada di Food-101 (rendang, gudeg, dll.)
///    otomatis fallback ke pencarian manual.
/// 3. Saat ini: backend heuristik + slot injeksi TFLite/MLKit agar alur
///    Scan -> Koreksi -> Simpan ke Diary bisa jalan end-to-end di emulator
///    sebelum file `.tflite` (≈12MB) ditambahkan ke `assets/models/`.
///
/// Cara pasang model asli (satu langkah):
/// ```dart
/// final svc = AiFoodService();
/// svc.registerOnDeviceClassifier((image) async {
///   // panggil tflite_flutter / google_mlkit di sini,
///   // kembalikan List<FoodPrediction> mentah.
///   return <FoodPrediction>[];
/// });
/// ```
class AiFoodService {
  /// Batas kepercayaan minimum (F-02.3). Di bawah ini, UI wajib
  /// meminta pengguna memilih manual dari kandidat teratas.
  static const double confidenceThreshold = 0.5;

  static final AiFoodService _instance = AiFoodService._internal();
  factory AiFoodService() => _instance;
  AiFoodService._internal();

  Future<List<FoodPrediction>> Function(File image)? _onDeviceClassifier;

  void registerOnDeviceClassifier(
    Future<List<FoodPrediction>> Function(File image) fn,
  ) {
    _onDeviceClassifier = fn;
  }

  bool get hasOnDeviceModel => _onDeviceClassifier != null;

  /// Klasifikasi utama. Pakai model on-device bila terdaftar,
  /// sonst heuristik (demo) agar flow tetap bisa diuji.
  Future<List<FoodPrediction>> classify(File image) async {
    if (_onDeviceClassifier != null) {
      final raw = await _onDeviceClassifier!(image);
      return raw.map(_attachMapping).toList();
    }
    return classifyHeuristic(image.path);
  }

  /// Heuristik demo: tebak dari nama file + beri kandidat umum.
  /// Dipakai saat file .tflite belum dibundel / di unit test.
  List<FoodPrediction> classifyHeuristic(String imagePath) {
    final name = imagePath.toLowerCase();
    final hits = <FoodPrediction>[];
    for (final entry in _labelToFoodId.entries) {
      final key = entry.key;
      if (name.contains(key)) {
        hits.add(
          FoodPrediction(
            label: key,
            confidence: 0.72,
            foodItemId: entry.value,
          ),
        );
      }
    }
    // Kandidat umum agar UI koreksi selalu punya 3 opsi (F-02.3).
    const fallbacks = [
      FoodPrediction(
        label: 'cooked rice',
        confidence: 0.45,
        foodItemId: 'nasi_putih',
      ),
      FoodPrediction(
        label: 'fried chicken',
        confidence: 0.38,
        foodItemId: 'ayam_goreng',
      ),
      FoodPrediction(
        label: 'banana',
        confidence: 0.31,
        foodItemId: 'pisang',
      ),
    ];
    for (final f in fallbacks) {
      if (hits.length >= 3) break;
      if (!hits.any((h) => h.foodItemId == f.foodItemId)) hits.add(f);
    }
    return hits;
  }

  FoodPrediction _attachMapping(FoodPrediction raw) {
    if (raw.foodItemId != null) return raw;
    final mapped = mapLabelToFoodId(raw.label);
    return FoodPrediction(
      label: raw.label,
      confidence: raw.confidence,
      foodItemId: mapped,
    );
  }

  /// Mapping label Inggris (Food-101 / ML Kit) -> id TKPI lokal.
  /// Return null bila di luar 25 item -> UI arahkan ke pencarian manual.
  String? mapLabelToFoodId(String rawLabel) {
    final label = rawLabel.toLowerCase().trim();
    if (_labelToFoodId.containsKey(label)) return _labelToFoodId[label];
    for (final entry in _labelToFoodId.entries) {
      if (label.contains(entry.key) || entry.key.contains(label)) {
        return entry.value;
      }
    }
    // Fuzzy per kata.
    final words = label.split(RegExp(r'[^a-z]+'));
    for (final w in words) {
      if (w.length < 3) continue;
      for (final entry in _labelToFoodId.entries) {
        if (entry.key.contains(w)) return entry.value;
      }
    }
    return null;
  }

  /// Kamus label model -> [FoodItem.id]. Kunci harus lowercase.
  static const Map<String, String> _labelToFoodId = {
    // Karbohidrat
    'cooked rice': 'nasi_putih',
    'fried rice': 'nasi_putih',
    'white rice': 'nasi_putih',
    'brown rice': 'nasi_merah',
    'bread': 'roti_gandum',
    'whole wheat bread': 'roti_gandum',
    'sweet potato': 'ubi_jalar',
    'cassava': 'singkong',
    // Protein hewani
    'fried chicken': 'ayam_goreng',
    'roast chicken': 'ayam_goreng',
    'grilled fish': 'ikan_goreng',
    'fried fish': 'ikan_goreng',
    'boiled egg': 'telur_ayam',
    'fried egg': 'telur_ayam',
    'egg': 'telur_ayam',
    'beef': 'daging_sapi',
    'steak': 'daging_sapi',
    'shrimp': 'udang',
    'prawn': 'udang',
    // Protein nabati
    'tofu': 'tahu',
    'tempeh': 'tempe',
    'red bean': 'kacang_merah',
    'kidney bean': 'kacang_merah',
    // Sayur
    'spinach': 'bayam',
    'water spinach': 'kangkung',
    'broccoli': 'brokoli',
    'carrot': 'wortel',
    // Buah
    'banana': 'pisang',
    'papaya': 'pepaya',
    'apple': 'apel',
    'orange': 'jeruk',
    'orange juice': 'jus_jeruk',
    // Susu & olahan
    'milk': 'susu_sapi',
    'cheese': 'keju',
    'yogurt': 'yogurt',
    'yoghurt': 'yogurt',
  };
}
