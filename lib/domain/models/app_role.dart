/// Peran pengguna. Satu akun satu peran (PRD Bagian 3, OQ-3).
///
/// Selaras dengan enum Supabase `user_role`:
/// 'ibu_balita' | 'ibu_hamil' | 'kader'.
enum AppRole {
  ibuBalita('Ibu Balita', 'Orang tua / pengasuh balita', 'ibu_balita'),
  ibuHamil('Ibu Hamil', 'Ibu hamil', 'ibu_hamil'),
  kader('Kader', 'Kader Posyandu', 'kader');

  const AppRole(this.label, this.description, this.dbCode);

  final String label;
  final String description;

  /// Kode untuk database (enum Supabase `user_role`).
  final String dbCode;

  String get code => dbCode;

  static AppRole fromCode(String? code) {
    return AppRole.values.firstWhere(
      (AppRole role) => role.dbCode == code || role.name == code,
      orElse: () => AppRole.ibuBalita,
    );
  }
}
