import 'user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String emailOrPhone;
  final UserRole role;
  final String? avatarUrl;
  final String? childName;
  final int? childAgeMonths;
  final int? pregnancyWeeks;
  final String? posyanduName;

  UserModel({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    required this.role,
    this.avatarUrl,
    this.childName,
    this.childAgeMonths,
    this.pregnancyWeeks,
    this.posyanduName,
  });

  String get roleDisplayTitle => role.title;

  String get roleSubtitle {
    switch (role) {
      case UserRole.ibuBalita:
        return childName != null
            ? 'Ibu dari $childName ($childAgeMonths bulan)'
            : 'Ibu Balita';
      case UserRole.ibuHamil:
        return pregnancyWeeks != null
            ? 'Usia Kehamilan $pregnancyWeeks Minggu'
            : 'Ibu Hamil';
      case UserRole.kaderPosyandu:
        return posyanduName != null
            ? 'Kader Posyandu $posyanduName'
            : 'Kader Posyandu Desa';
    }
  }

  factory UserModel.demoIbuBalita() {
    return UserModel(
      id: 'usr_01',
      name: 'Diva Putri Adilla',
      emailOrPhone: 'divaputri@gmail.com',
      role: UserRole.ibuBalita,
      childName: 'Reyhan',
      childAgeMonths: 18,
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
    );
  }

  factory UserModel.demoIbuHamil() {
    return UserModel(
      id: 'usr_02',
      name: 'Siti Rahmawati',
      emailOrPhone: 'sitirahma@gmail.com',
      role: UserRole.ibuHamil,
      pregnancyWeeks: 24,
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
    );
  }

  factory UserModel.demoKader() {
    return UserModel(
      id: 'usr_03',
      name: 'Kader Nurul Hidayah',
      emailOrPhone: '081234567890',
      role: UserRole.kaderPosyandu,
      posyanduName: 'Melati Desa Sukamaju',
      avatarUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop',
    );
  }
}
