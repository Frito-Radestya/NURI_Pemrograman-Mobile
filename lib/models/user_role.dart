import 'package:flutter/material.dart';

enum UserRole {
  ibuBalita,
  ibuHamil,
  kaderPosyandu,
}

extension UserRoleExtension on UserRole {
  String get title {
    switch (this) {
      case UserRole.ibuBalita:
        return 'Ibu Balita';
      case UserRole.ibuHamil:
        return 'Ibu Hamil';
      case UserRole.kaderPosyandu:
        return 'Kader Posyandu';
    }
  }

  String get description {
    switch (this) {
      case UserRole.ibuBalita:
        return 'Pantau gizi harian & deteksi risiko stunting si kecil';
      case UserRole.ibuHamil:
        return 'Monitoring kebutuhan gizi harian selama masa kehamilan';
      case UserRole.kaderPosyandu:
        return 'Skrining stunting masal & pengelolaan data kesehatan desa';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.ibuBalita:
        return Icons.child_care_rounded;
      case UserRole.ibuHamil:
        return Icons.pregnant_woman_rounded;
      case UserRole.kaderPosyandu:
        return Icons.badge_outlined;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.ibuBalita:
        return const Color(0xFF00C9A7);
      case UserRole.ibuHamil:
        return const Color(0xFFFF7043);
      case UserRole.kaderPosyandu:
        return const Color(0xFF26A69A);
    }
  }

  Color get bgLight {
    switch (this) {
      case UserRole.ibuBalita:
        return const Color(0xFFE0F7FA);
      case UserRole.ibuHamil:
        return const Color(0xFFFBE9E7);
      case UserRole.kaderPosyandu:
        return const Color(0xFFE0F2F1);
    }
  }
}
