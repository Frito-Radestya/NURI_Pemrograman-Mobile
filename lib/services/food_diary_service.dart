import 'package:flutter/material.dart';

import '../data/food_database.dart';
import '../models/food_entry.dart';

/// Service untuk menyimpan dan mengambil data food diary.
///
/// Data masih berupa simulasi in-memory, tetapi sudah diisolasi berdasarkan
/// relasi [FoodEntry.userId] dan tanggal agar tidak bocor antar pengguna.
class FoodDiaryService {
  // Singleton
  static final FoodDiaryService _instance = FoodDiaryService._internal();
  factory FoodDiaryService() => _instance;
  FoodDiaryService._internal() {
    _seedDemoData();
  }

  // key = 'userId|YYYY-MM-DD', value = list of entries
  final Map<String, List<FoodEntry>> _diary = {};
  int _idCounter = 0;

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _storageKey(String userId, DateTime date) =>
      '$userId|${dateKey(date)}';

  /// Ambil semua entry milik user pada tanggal tertentu.
  List<FoodEntry> getEntries({required String userId, required DateTime date}) {
    return List.unmodifiable(_diary[_storageKey(userId, date)] ?? const []);
  }

  /// Ambil entry milik user berdasarkan sesi.
  List<FoodEntry> getEntriesBySession({
    required String userId,
    required DateTime date,
    required String session,
  }) {
    return getEntries(
      userId: userId,
      date: date,
    ).where((e) => e.session == session).toList();
  }

  /// Tambah entry baru (Create).
  void addEntry(DateTime date, FoodEntry entry) {
    if (entry.userId.isEmpty) {
      throw ArgumentError('FoodEntry harus memiliki userId.');
    }
    if (entry.foodItemId.isEmpty || entry.categoryId.isEmpty) {
      throw ArgumentError('FoodEntry harus memiliki relasi makanan/kategori.');
    }
    final key = _storageKey(entry.userId, date);
    _diary.putIfAbsent(key, () => []);
    _diary[key]!.removeWhere((e) => e.id == entry.id);
    _diary[key]!.add(entry);
  }

  /// Perbarui entry yang sudah ada (Update).
  void updateEntry(DateTime date, FoodEntry entry) {
    final key = _storageKey(entry.userId, date);
    final entries = _diary[key];
    if (entries == null) {
      throw StateError('Entry tidak ditemukan untuk diperbarui.');
    }
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      throw StateError('Entry dengan id ${entry.id} tidak ditemukan.');
    }
    entries[index] = entry;
  }

  /// Hapus entry berdasarkan id (Delete).
  void removeEntry({
    required String userId,
    required DateTime date,
    required String entryId,
  }) {
    final key = _storageKey(userId, date);
    if (_diary.containsKey(key)) {
      _diary[key]!.removeWhere((e) => e.id == entryId);
    }
  }

  /// Entry berdasarkan id untuk pengguna tertentu.
  FoodEntry? findEntry({
    required String userId,
    required DateTime date,
    required String entryId,
  }) {
    for (final entry in getEntries(userId: userId, date: date)) {
      if (entry.id == entryId) return entry;
    }
    return null;
  }

  /// Ringkasan gizi harian.
  DailyNutritionSummary getSummary({
    required String userId,
    required DateTime date,
  }) {
    return DailyNutritionSummary.fromEntries(
      getEntries(userId: userId, date: date),
    );
  }

  /// Ringkasan gizi per sesi.
  DailyNutritionSummary getSessionSummary({
    required String userId,
    required DateTime date,
    required String session,
  }) {
    return DailyNutritionSummary.fromEntries(
      getEntriesBySession(userId: userId, date: date, session: session),
    );
  }

  /// Bersihkan semua data (untuk testing).
  void clear() => _diary.clear();

  /// Mengembalikan data ke kondisi demo (untuk testing).
  void resetDemoData() {
    _diary.clear();
    _seedDemoData();
  }

  /// Daftar sesi makan.
  static const List<String> sessions = ['pagi', 'siang', 'malam', 'snack'];

  static String sessionLabel(String session) {
    switch (session) {
      case 'pagi':
        return 'Sarapan Pagi';
      case 'siang':
        return 'Makan Siang';
      case 'malam':
        return 'Makan Malam';
      case 'snack':
        return 'Camilan';
      default:
        return session;
    }
  }

  static IconData sessionIcon(String session) {
    switch (session) {
      case 'pagi':
        return Icons.breakfast_dining_outlined;
      case 'siang':
        return Icons.wb_sunny_outlined;
      case 'malam':
        return Icons.nights_stay_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  /// Generate unique id untuk entry baru.
  String generateId() {
    _idCounter++;
    return 'entry_${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  void _seedDemoData() {
    final today = DateTime.now();
    final seeds = <String, List<(String, String, double, String?)>>{
      'usr_01': [
        ('nasi_putih', 'pagi', 150, 'child_reyhan'),
        ('ayam_goreng', 'siang', 80, 'child_reyhan'),
        ('susu_sapi', 'snack', 200, 'child_reyhan'),
      ],
      'usr_02': [
        ('nasi_merah', 'pagi', 150, 'child_salsabila'),
        ('brokoli', 'siang', 100, 'child_salsabila'),
        ('telur_ayam', 'malam', 55, 'child_salsabila'),
      ],
      'usr_03': [
        ('kangkung', 'pagi', 100, 'child_kader_1'),
        ('ikan_goreng', 'siang', 60, 'child_kader_1'),
      ],
    };

    seeds.forEach((userId, rows) {
      for (final row in rows) {
        final food = FoodDatabase.findById(row.$1);
        if (food == null) continue;
        addEntry(
          today,
          food.toEntry(
            entryId: 'seed_${userId}_${row.$1}',
            userId: userId,
            dateKey: dateKey(today),
            session: row.$2,
            gram: row.$3,
            childId: row.$4,
          ),
        );
      }
    });
  }
}
