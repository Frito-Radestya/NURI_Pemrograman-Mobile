import '../models/food_entry.dart';

/// Service untuk menyimpan dan mengambil data food diary
/// Menggunakan in-memory storage (dapat diganti Supabase di masa depan)
class FoodDiaryService {
  // Singleton
  static final FoodDiaryService _instance = FoodDiaryService._internal();
  factory FoodDiaryService() => _instance;
  FoodDiaryService._internal();

  // In-memory storage: key = 'YYYY-MM-DD', value = list of entries
  final Map<String, List<FoodEntry>> _diary = {};

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Ambil semua entry untuk tanggal tertentu
  List<FoodEntry> getEntries(DateTime date) {
    final key = _dateKey(date);
    return List.unmodifiable(_diary[key] ?? []);
  }

  /// Ambil entry berdasarkan sesi
  List<FoodEntry> getEntriesBySession(DateTime date, String session) {
    return getEntries(date).where((e) => e.session == session).toList();
  }

  /// Tambah entry baru
  void addEntry(DateTime date, FoodEntry entry) {
    final key = _dateKey(date);
    _diary.putIfAbsent(key, () => []);
    _diary[key]!.add(entry);
  }

  /// Hapus entry berdasarkan id
  void removeEntry(DateTime date, String entryId) {
    final key = _dateKey(date);
    if (_diary.containsKey(key)) {
      _diary[key]!.removeWhere((e) => e.id == entryId);
    }
  }

  /// Ringkasan gizi harian
  DailyNutritionSummary getSummary(DateTime date) {
    return DailyNutritionSummary.fromEntries(getEntries(date));
  }

  /// Ringkasan gizi per sesi
  DailyNutritionSummary getSessionSummary(DateTime date, String session) {
    return DailyNutritionSummary.fromEntries(
      getEntriesBySession(date, session),
    );
  }

  /// Bersihkan semua data (untuk testing)
  void clear() => _diary.clear();

  /// Daftar sesi makan
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

  static String sessionIcon(String session) {
    switch (session) {
      case 'pagi':
        return '🌅';
      case 'siang':
        return '☀️';
      case 'malam':
        return '🌙';
      case 'snack':
        return '🍎';
      default:
        return '🍽️';
    }
  }

  /// Generate unique id untuk entry baru
  String generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_diary.length}';
}
