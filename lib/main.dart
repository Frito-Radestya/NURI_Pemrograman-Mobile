import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';
import 'data/app_controller.dart';
import 'data/app_repository.dart';
import 'data/auth_service.dart';
import 'data/demo_seed.dart';
import 'data/firestore_service.dart';
import 'data/local_repository.dart';
import 'data/sqlite_repository.dart';
import 'domain/growth/who_lms.dart';
import 'domain/nutrition/food_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  // Firebase dipakai untuk Authentication. Bila konfigurasi belum siap,
  // aplikasi tetap berjalan dengan penyimpanan lokal agar demo tidak macet.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 4));
    } catch (error) {
      debugPrint('Firebase gagal diinisialisasi: $error');
    }
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.naturalWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Muat data aset dan preferences secara paralel untuk mempercepat startup
  final results = await Future.wait([
    rootBundle.loadString('assets/data/who_hfa_boys.json'),
    rootBundle.loadString('assets/data/who_hfa_girls.json'),
    rootBundle.loadString('assets/data/tkpi_v1.json'),
    SharedPreferences.getInstance(),
  ]);

  final boysJson = results[0] as String;
  final girlsJson = results[1] as String;
  final tkpiJson = results[2] as String;
  final prefs = results[3] as SharedPreferences;

  final who = WhoReference(
    boys: WhoLmsTable.fromJsonString(boysJson),
    girls: WhoLmsTable.fromJsonString(girlsJson),
  );
  WhoReference.setInstance(who);
  FoodCatalog.setInstance(FoodCatalog.fromJsonString(tkpiJson));

  AppRepository repository;
  if (kIsWeb) {
    // sqflite tidak tersedia di web; preview web tetap memakai localStorage.
    repository = LocalRepository(prefs);
  } else {
    try {
      repository = await SqliteRepository.open(legacyPrefs: prefs);
    } catch (error) {
      debugPrint(
        'Gagal membuka SqliteRepository, fallback ke LocalRepository: $error',
      );
      repository = LocalRepository(prefs);
    }
  }
  final restored = repository.load();
  final initial = restored ?? DemoSeed.build(who: who);
  if (restored == null) {
    try {
      await repository.save(initial);
    } catch (e) {
      debugPrint('Gagal menyimpan state awal ke repository: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        localRepositoryProvider.overrideWithValue(repository),
        appControllerProvider.overrideWith(
          () => AppController(
            initial,
            repository,
            authService: FirebaseAuthService(),
            databaseService: FirestoreService(),
          ),
        ),
      ],
      child: const NuriApp(),
    ),
  );
}
