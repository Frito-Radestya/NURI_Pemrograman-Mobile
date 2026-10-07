/// Konfigurasi koneksi Supabase (NURI v2.0).
///
/// Kredensial diberikan saat build/run agar tidak ditulis di kode:
///
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
/// ```
///
/// Kunci yang dipakai di klien HARUS kunci publik (publishable/anon).
/// **JANGAN** pernah memakai `sb_secret_...` / `service_role` di aplikasi.
///
/// Bila kosong, aplikasi otomatis berjalan **offline-first** (mode demo).
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Nama baru (disarankan).
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Nama lama (anon key) — tetap didukung untuk kompatibilitas.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Kunci publik efektif yang dipakai klien.
  static String get key =>
      publishableKey.isNotEmpty ? publishableKey : anonKey;

  static bool get isConfigured => url.isNotEmpty && key.isNotEmpty;
}
