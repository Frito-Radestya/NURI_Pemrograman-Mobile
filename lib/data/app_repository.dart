import '../domain/models.dart';

/// Kontrak penyimpanan. Implementasi Firebase dapat menggantikan repository
/// lokal tanpa mengubah UI maupun controller (PRD §9.3).
abstract class AppRepository {
  AppState? load();
  Future<void> save(AppState state);
  Future<void> clear();
}
