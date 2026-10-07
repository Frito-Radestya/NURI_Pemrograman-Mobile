import 'nutrient.dart';
import 'sex.dart';

/// Kelompok Angka Kecukupan Gizi (Permenkes 28/2019).
class AkgGroup {
  const AkgGroup({
    required this.id,
    required this.label,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.targets,
    this.sex,
  });

  final String id;
  final String label;
  final int minAgeMonths;
  final int maxAgeMonths;
  final Sex? sex;
  final Map<Nutrient, double> targets;

  bool covers(int ageMonths, Sex childSex) {
    final bool inRange =
        ageMonths >= minAgeMonths && ageMonths <= maxAgeMonths;
    if (!inRange) return false;
    if (sex == null) return true;
    return sex == childSex;
  }

  double targetFor(Nutrient nutrient) => targets[nutrient] ?? 0;
}

/// Katalog AKG dari aset `akg.json`.
class AkgCatalog {
  const AkgCatalog({required this.refVersion, required this.groups});

  final String refVersion;
  final List<AkgGroup> groups;

  /// AKG dipilih otomatis dari umur dan jenis kelamin anak (F11).
  AkgGroup groupFor({required int ageMonths, required Sex sex}) {
    for (final AkgGroup group in groups) {
      if (group.covers(ageMonths, sex)) return group;
    }
    return groups.isEmpty
        ? const AkgGroup(
            id: 'fallback',
            label: '-',
            minAgeMonths: 0,
            maxAgeMonths: 999,
            targets: <Nutrient, double>{},
          )
        : groups.last;
  }
}
