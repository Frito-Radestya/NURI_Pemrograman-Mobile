import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nuri/app.dart';
import 'package:nuri/core/theme/app_theme.dart';
import 'package:nuri/data/app_controller.dart';
import 'package:nuri/data/demo_seed.dart';
import 'package:nuri/data/local_repository.dart';
import 'package:nuri/domain/growth/who_lms.dart';
import 'package:nuri/domain/nutrition/food_catalog.dart';

void main() {
  late AppRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID');
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
  });

  testWidgets('landing NURI tampil setelah splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = LocalRepository(prefs);
    final initial = DemoSeed.build(who: WhoReference.instance);

    await tester.pumpWidget(
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

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Pilih Peran Anda'), findsOneWidget);
    expect(find.textContaining('bukan diagnosis'), findsWidgets);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Pilih Peran Anda')))
          .style
          .color,
      AppColors.text,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
