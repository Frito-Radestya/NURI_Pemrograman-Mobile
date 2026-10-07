import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nuri_app/core/theme/app_theme.dart';
import 'package:nuri_app/state/app_state.dart';
import 'package:nuri_app/features/auth/email_sent_screen.dart';
import 'package:nuri_app/features/auth/forgot_screen.dart';
import 'package:nuri_app/features/auth/login_screen.dart';
import 'package:nuri_app/features/auth/register_screen.dart';
import 'package:nuri_app/features/auth/role_screen.dart';
import 'package:nuri_app/features/child/child_data_screen.dart';
import 'package:nuri_app/features/child/first_measure_screen.dart';
import 'package:nuri_app/features/gallery/design_gallery_screen.dart';
import 'package:nuri_app/features/home/growth_screen.dart';
import 'package:nuri_app/features/home/mom_home_screen.dart';
import 'package:nuri_app/features/home/nutrition_screen.dart';
import 'package:nuri_app/features/home/profile_screen.dart';
import 'package:nuri_app/features/kader/kader_activity_screen.dart';
import 'package:nuri_app/features/kader/kader_entry_screen.dart';
import 'package:nuri_app/features/kader/kader_home_screen.dart';
import 'package:nuri_app/features/kader/kader_result_screen.dart';
import 'package:nuri_app/features/kader/kader_target_detail_screen.dart';
import 'package:nuri_app/features/kader/kader_targets_screen.dart';
import 'package:nuri_app/features/notifications/notifications_screen.dart';
import 'package:nuri_app/features/nutrition/meal_analyzing_screen.dart';
import 'package:nuri_app/features/nutrition/meal_fail_screen.dart';
import 'package:nuri_app/features/nutrition/meal_history_screen.dart';
import 'package:nuri_app/features/nutrition/meal_result_screen.dart';
import 'package:nuri_app/features/nutrition/meal_review_screen.dart';
import 'package:nuri_app/features/nutrition/plate_camera_screen.dart';
import 'package:nuri_app/features/onboarding/onboarding_screen.dart';
import 'package:nuri_app/features/pregnancy/pregnant_home_screen.dart';
import 'package:nuri_app/features/pregnancy/pregnant_monitor_screen.dart';
import 'package:nuri_app/features/pregnancy/pregnant_nutrition_screen.dart';
import 'package:nuri_app/features/pregnancy/pregnant_recommend_screen.dart';
import 'package:nuri_app/features/screening/posture_camera_screen.dart';
import 'package:nuri_app/features/screening/screening_result_screen.dart';
import 'package:nuri_app/features/screening/screening_start_screen.dart';
import 'package:nuri_app/features/settings/settings_screen.dart';
import 'package:nuri_app/features/splash/splash_screen.dart';

import 'test_http_overrides.dart';

final Map<String, Widget Function()> _screens = {
  'Splash': () => const SplashScreen(),
  'Onboarding': () => const OnboardingScreen(),
  'Gallery': () => const DesignGalleryScreen(),
  'Pilih Peran': () => const RoleSelectScreen(),
  'Masuk': () => const LoginScreen(),
  'Daftar': () => const RegisterScreen(),
  'Lupa Sandi': () => const ForgotPasswordScreen(),
  'Email Terkirim': () => const EmailSentScreen(),
  'Data Anak': () => const ChildDataScreen(),
  'Pengukuran Perdana': () => const FirstMeasureScreen(),
  'Beranda Ibu': () => const MomHomeScreen(),
  'Tumbuh': () => const GrowthScreen(),
  'Gizi': () => const NutritionScreen(),
  'Profil': () => const ProfileScreen(),
  'Skrining Anak': () => const ScreeningStartScreen(),
  'Hasil Skrining': () => const ScreeningResultScreen(),
  'Kamera Postur': () => const PostureCameraScreen(),
  'Kamera Piring': () => const PlateCameraScreen(),
  'Ulas Piring': () => const MealReviewScreen(),
  'Analisis Gizi': () => const MealAnalyzingScreen(),
  'Hasil Analisis': () => const MealResultScreen(),
  'Analisis Gagal': () => const MealFailScreen(),
  'Riwayat Gizi': () => const MealHistoryScreen(),
  'Beranda Hamil': () => const PregnantHomeScreen(),
  'Nutrisi Hamil': () => const PregnantNutritionScreen(),
  'Pantau Hamil': () => const PregnantMonitorScreen(),
  'Rekomendasi Hamil': () => const PregnantRecommendScreen(),
  'Beranda Kader': () => const KaderHomeScreen(),
  'Daftar Sasaran': () => const KaderTargetsScreen(),
  'Detail Sasaran': () => const KaderTargetDetailScreen(),
  'Input Kader': () => const KaderEntryScreen(),
  'Hasil Kader': () => const KaderResultScreen(),
  'Aktivitas Kader': () => const KaderActivityScreen(),
  'Notifikasi': () => const NotificationsScreen(),
  'Pengaturan': () => const SettingsScreen(),
};

/// Ukuran device representatif: ponsel kecil s/d tablet & desktop lebar.
const List<Size> _sizes = [
  Size(320, 568), // ponsel sangat kecil (iPhone SE 1)
  Size(360, 800), // Android umum
  Size(390, 844), // iPhone 14
  Size(412, 915), // Android besar
  Size(430, 932), // iPhone Pro Max
  Size(600, 1024), // tablet kecil / foldable
  Size(834, 1112), // tablet portrait
  Size(1280, 800), // desktop / landscape
];

late NuriAppState _state;

Widget _harness(Widget screen) {
  final router = GoRouter(
    initialLocation: '/screen',
    routes: [
      GoRoute(path: '/screen', builder: (_, _) => screen),
      GoRoute(path: '/:rest(.*)', builder: (_, _) => const SizedBox.shrink()),
    ],
  );
  return NuriScope(
    state: _state,
    child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
}

Future<void> _renderAndScan(
  WidgetTester tester,
  Size size,
  Widget screen,
  void Function(Object error) onError,
) async {
  tester.view.physicalSize = Size(size.width, size.height);
  tester.view.devicePixelRatio = 1.0;

  void drain() {
    Object? ex = tester.takeException();
    while (ex != null) {
      onError(ex);
      ex = tester.takeException();
    }
  }

  await tester.pumpWidget(_harness(screen));
  drain();
  await tester.pump(const Duration(seconds: 4));
  drain();

  for (var i = 0; i < 6; i++) {
    await tester.dragFrom(
      Offset(size.width / 2, size.height * 0.7),
      const Offset(0, -320),
    );
    await tester.pump(const Duration(milliseconds: 200));
    drain();
  }
}

/// Ambil baris penting: pesan + lokasi widget penyebab.
String _summarize(Object error) {
  final lines = error
      .toString()
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty);
  final message = lines.firstWhere(
    (l) => l.contains('overflowed'),
    orElse: () => lines.first,
  );
  final location = lines.firstWhere(
    (l) => l.contains('lib${Platform.pathSeparator}') ||
        l.contains('lib/') ||
        l.contains('lib\\'),
    orElse: () => '',
  );
  return location.isEmpty ? message : '$message  <-  $location';
}

/// Muat font asli agar lebar teks sama seperti di aplikasi nyata
/// (test default memakai font "Ahem" yang jauh lebih lebar).
Future<void> _loadFonts() async {
  final loader = FontLoader('PlusJakartaSans')
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-ExtraBold.ttf'));
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    await _loadFonts();
    _state = await NuriAppState.bootstrap();
  });

  for (final entry in _screens.entries) {
    testWidgets(entry.key, (tester) async {
      addTearDown(tester.view.reset);
      final errors = <String>[];
      var currentSize = '';

      for (final size in _sizes) {
        currentSize = '${size.width.toInt()}x${size.height.toInt()}';
        await _renderAndScan(
          tester,
          size,
          entry.value(),
          (error) => errors.add('[$currentSize] ${_summarize(error)}'),
        );
      }

      final unique = errors.toSet().toList();
      expect(unique, isEmpty, reason: unique.join('\n'));
    });
  }
}
