import 'dart:io';

import 'package:flutter/material.dart' show Scrollable;
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:nuri_app/app.dart';
import 'package:nuri_app/router.dart';
import 'package:nuri_app/state/app_state.dart';

import 'test_http_overrides.dart';

Future<void> _loadFonts() async {
  final loader = FontLoader('PlusJakartaSans')
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-ExtraBold.ttf'));
  await loader.load();
}

late NuriAppState _state;

String _path() => appRouter.routerDelegate.currentConfiguration.uri.path;

Future<void> _go(WidgetTester tester, String path) async {
  appRouter.go(path);
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _tap(WidgetTester tester, String label, {bool settle = false}) async {
  if (find.text(label).evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.text(label),
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  final finder = find.text(label).first;
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 900));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    await _loadFonts();
  });

  setUp(() async {
    _state = await NuriAppState.bootstrap();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(NuriScope(state: _state, child: const NuriApp()));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('Splash otomatis lanjut ke Onboarding', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(_path(), '/onboarding');
  });

  testWidgets('Onboarding -> Pilih Peran -> Data Anak', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(seconds: 3));

    await _tap(tester, 'Lanjut', settle: true);
    await _tap(tester, 'Lanjut', settle: true);
    await _tap(tester, 'Mulai Sekarang', settle: true);
    expect(_path(), '/role');

    await _tap(tester, 'Lanjutkan', settle: true);
    expect(_path(), '/child-data');
  });

  testWidgets('Login -> Beranda ibu', (tester) async {
    await pumpApp(tester);
    await _go(tester, '/login');
    await _tap(tester, 'Masuk ke NURI');
    expect(_path(), '/home');
  });

  testWidgets('Navigasi bawah ibu berpindah tab', (tester) async {
    await pumpApp(tester);
    await _go(tester, '/home');

    await _tap(tester, 'Tumbuh');
    expect(_path(), '/growth');

    await _tap(tester, 'Gizi');
    expect(_path(), '/nutrition');

    await _tap(tester, 'Profil');
    expect(_path(), '/profile');

    await _tap(tester, 'Beranda');
    expect(_path(), '/home');
  });

  testWidgets('Alur analisis piring makan', (tester) async {
    await pumpApp(tester);
    await _go(tester, '/nutrition');

    await _tap(tester, 'Pindai Piring Makan Sekarang');
    expect(_path(), '/camera-plate');

    await _go(tester, '/meal-review');
    expect(_path(), '/meal-review');
    await _go(tester, '/meal-result');
    expect(_path(), '/meal-result');
  });

  testWidgets('Navigasi kader berpindah tab', (tester) async {
    await pumpApp(tester);
    await _go(tester, '/kader');

    await _tap(tester, 'Sasaran');
    expect(_path(), '/kader-targets');
  });

  testWidgets('Navigasi ibu hamil berpindah tab', (tester) async {
    await pumpApp(tester);
    await _go(tester, '/pregnant');

    await _tap(tester, 'Nutrisi');
    expect(_path(), '/pregnant-nutrition');
  });

  testWidgets('Pengaturan dan Notifikasi dapat dibuka', (tester) async {
    await pumpApp(tester);
    await _go(tester, '/settings');
    expect(_path(), '/settings');

    await _go(tester, '/notifications');
    expect(_path(), '/notifications');
  });
}
