import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/app_controller.dart';
import 'data/app_repository.dart';
import 'data/demo_seed.dart';
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
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint('Firebase gagal diinisialisasi: $error');
    }
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final who = WhoReference(
    boys: WhoLmsTable.fromJsonString(
      await rootBundle.loadString('assets/data/who_hfa_boys.json'),
    ),
    girls: WhoLmsTable.fromJsonString(
      await rootBundle.loadString('assets/data/who_hfa_girls.json'),
    ),
  );
  WhoReference.setInstance(who);
  FoodCatalog.setInstance(
    FoodCatalog.fromJsonString(
      await rootBundle.loadString('assets/data/tkpi_v1.json'),
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final AppRepository repository;
  if (kIsWeb) {
    // sqflite tidak tersedia di web; preview web tetap memakai localStorage.
    repository = LocalRepository(prefs);
  } else {
    repository = await SqliteRepository.open(legacyPrefs: prefs);
  }
  final restored = repository.load();
  final initial = restored ?? DemoSeed.build(who: who);
  if (restored == null) {
    await repository.save(initial);
  }

  runApp(
    ProviderScope(
      overrides: [
        localRepositoryProvider.overrideWithValue(repository),
        appControllerProvider.overrideWith(
          () => AppController(initial, repository),
        ),
      ],
      child: const NuriApp(),
    ),
  );
}
