import 'package:flutter/material.dart';

/// Token warna NURI v2.
///
/// Diambil dari referensi desain Stitch: latar krem hangat, kartu putih
/// membulat, hijau forest untuk aksi utama, dan aksen pastel lembut.
class AppColors {
  AppColors._();

  // ---- Kanvas & permukaan ---------------------------------------------------
  /// Latar krem hangat (sebagian besar layar).
  static const Color canvas = Color(0xFFF6F4EF);

  /// Latar mint sangat lembut (auth, data anak, pengaturan).
  static const Color canvasMint = Color(0xFFEDF3EA);

  /// Hijau kanvas lebih pekat (kartu ringkasan).
  static const Color canvasGreen = Color(0xFFE8F0E5);

  /// Permukaan putih murni untuk kartu.
  static const Color surface = Color(0xFFFFFFFF);

  /// Permukaan abu-hijau lembut untuk kartu sekunder.
  static const Color surfaceSoft = Color(0xFFF3F6F1);

  /// Permukaan krem untuk kartu catatan.
  static const Color surfaceSand = Color(0xFFFAF4E6);

  // ---- Teks -----------------------------------------------------------------
  static const Color ink = Color(0xFF17231C);
  static const Color inkSoft = Color(0xFF5B6B61);
  static const Color inkFaint = Color(0xFF96A39A);
  static const Color onDark = Color(0xFFFFFFFF);

  // ---- Brand -----------------------------------------------------------------
  /// Hijau forest — tombol & elemen aksi utama.
  static const Color brand = Color(0xFF35694E);
  static const Color brandDark = Color(0xFF2A543E);
  static const Color brandDeep = Color(0xFF1E4232);

  /// Hijau teks logo "nuri".
  static const Color brandText = Color(0xFF2E7A57);

  /// Aksen oranye.
  static const Color accent = Color(0xFFF2994A);

  // ---- Garis -----------------------------------------------------------------
  static const Color line = Color(0xFFE7EBE2);
  static const Color lineSoft = Color(0xFFF0F3EB);
  static const Color lineStrong = Color(0xFFCBD5C8);

  // ---- Pastel -----------------------------------------------------------------
  static const Color pastelGreen = Color(0xFFDCEBD9);
  static const Color pastelGreenSoft = Color(0xFFEAF2E6);
  static const Color pastelPink = Color(0xFFF8DFE1);
  static const Color pastelPeach = Color(0xFFFBE3CF);
  static const Color pastelBlue = Color(0xFFDCE9F6);
  static const Color pastelYellow = Color(0xFFF6EAC4);
  static const Color pastelSand = Color(0xFFF1E9DA);
  static const Color pastelPurple = Color(0xFFE6E0F3);

  // ---- Warna status gizi (PRD Bagian 10) ------------------------------------
  static const Color statusNormal = Color(0xFF2E9E5B);
  static const Color statusPendek = Color(0xFFE0A100);
  static const Color statusSangatPendek = Color(0xFFC93C3C);
  static const Color statusTinggi = Color(0xFF2F6FB5);
  static const Color statusNormalSoft = Color(0xFFDCF0E3);
  static const Color statusPendekSoft = Color(0xFFFBEFCF);
  static const Color statusSangatPendekSoft = Color(0xFFF8DDDD);
  static const Color statusTinggiSoft = Color(0xFFDCE7F5);

  // ---- Nutrisi ---------------------------------------------------------------
  static const Color carb = Color(0xFFE4574C);
  static const Color protein = Color(0xFFE4574C);
  static const Color fat = Color(0xFFE0A100);
  static const Color iron = Color(0xFF9B59B6);
  static const Color zinc = Color(0xFF35694E);
  static const Color calcium = Color(0xFF2F6FB5);
  static const Color vitaminA = Color(0xFFF2994A);
  static const Color energy = Color(0xFF35694E);

  // ---- Navigasi --------------------------------------------------------------
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF9AA69C);
  static const Color navDark = Color(0xFF1C1C1C);

  // ---- Kamera (overlay gelap) ------------------------------------------------
  static const Color cameraScrim = Color(0xFF1D211D);
  static const Color cameraSheet = Color(0xFF2A2F2A);

  // ---- Gradien ---------------------------------------------------------------
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E7557), Color(0xFF2A543E)],
  );

  static const LinearGradient splashGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDF3E9), Color(0xFFF6F4EF), Color(0xFFF6F4EF)],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient skyGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE7F1EA), Color(0xFFF6F4EF)],
  );
}
