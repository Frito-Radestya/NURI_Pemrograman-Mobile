/// Jenis kelamin anak. Menentukan tabel LMS yang dipakai (PRD Bagian 6).
enum Sex {
  lakiLaki('Laki-laki', 'L', 'boys'),
  perempuan('Perempuan', 'P', 'girls');

  const Sex(this.label, this.short, this.lmsKey);

  final String label;
  final String short;

  /// Kunci tabel LMS pada aset referensi.
  final String lmsKey;

  String get code => name;

  /// Kode untuk database (enum Supabase `child_sex`: 'L' / 'P').
  String get dbCode => this == Sex.lakiLaki ? 'L' : 'P';

  static Sex fromDb(String? code) =>
      code == 'L' ? Sex.lakiLaki : Sex.perempuan;

  static Sex fromCode(String? code) {
    return Sex.values.firstWhere(
      (Sex sex) => sex.name == code,
      orElse: () => Sex.lakiLaki,
    );
  }
}
