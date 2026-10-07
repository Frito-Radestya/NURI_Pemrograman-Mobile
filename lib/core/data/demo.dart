/// Data demo & aset foto untuk prototipe NURI v2.
///
/// Semua nilai di sini meniru isi desain referensi (Stitch) supaya layar
/// terlihat hidup tanpa backend. Foto memakai URL Unsplash; bila jaringan
/// tidak tersedia, [NuriPhoto] otomatis menampilkan gradien cadangan.
class DemoImages {
  DemoImages._();

  static const String heroFood =
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80';
  static const String measuredChild =
      'https://images.unsplash.com/photo-1544126592-807ade215a0b?auto=format&fit=crop&w=1200&q=80';
  static const String babyFeet =
      'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=1200&q=80';
  static const String plateMeal =
      'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=1200&q=80';
  static const String riceFish =
      'https://images.unsplash.com/photo-1539136788836-5699e78bfc75?auto=format&fit=crop&w=1200&q=80';
  static const String pregnancy =
      'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?auto=format&fit=crop&w=1200&q=80';
  static const String toddlerEat =
      'https://images.unsplash.com/photo-1516684732162-798a0062be99?auto=format&fit=crop&w=1200&q=80';
  static const String kids =
      'https://images.unsplash.com/photo-1526634332515-d56c5fd16991?auto=format&fit=crop&w=1200&q=80';
  static const String cameraKid =
      'https://images.unsplash.com/photo-1476703993599-0035a21b17a9?auto=format&fit=crop&w=1200&q=80';
  static const String motherBaby =
      'https://images.unsplash.com/photo-1493894473891-10fc1e5dbd22?auto=format&fit=crop&w=1200&q=80';
  static const String veggies =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1200&q=80';
  static const String cooking =
      'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?auto=format&fit=crop&w=1200&q=80';
  static const String avatarMother =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80';
  static const String avatarChild =
      'https://images.unsplash.com/photo-1519457431-44ccd64a579b?auto=format&fit=crop&w=400&q=80';
}

/// Profil anak yang dipakai lintas layar (contoh pada desain: Fatih).
class DemoKid {
  const DemoKid({
    this.name = 'Muhammad Al-Fatih',
    this.nickname = 'Fatih',
    this.age = '18 Bulan',
    this.gender = 'Laki-laki',
    this.birthDate = '14 Agustus 2023',
    this.weight = '10.4',
    this.height = '82.5',
    this.headCirc = '46.0',
    this.avatar = DemoImages.avatarChild,
  });

  final String name;
  final String nickname;
  final String age;
  final String gender;
  final String birthDate;
  final String weight;
  final String height;
  final String headCirc;
  final String avatar;
}

const DemoKid demoKid = DemoKid();

/// Profil bunda (pengguna contoh).
class DemoMom {
  const DemoMom({
    this.name = 'Bunda Siti',
    this.fullName = 'Bunda Siti Aminah',
    this.posyandu = 'Posyandu Melati RW 04',
    this.role = 'Ibu Balita',
    this.avatar = DemoImages.avatarMother,
  });

  final String name;
  final String fullName;
  final String posyandu;
  final String role;
  final String avatar;
}

const DemoMom demoMom = DemoMom();

/// Satu baris catatan makan untuk riwayat.
class DemoMeal {
  const DemoMeal({
    required this.time,
    required this.label,
    required this.title,
    required this.energy,
    required this.protein,
    required this.iron,
    required this.status,
    this.image = DemoImages.plateMeal,
  });

  final String time;
  final String label;
  final String title;
  final String energy;
  final String protein;
  final String iron;
  final String status;
  final String image;
}
