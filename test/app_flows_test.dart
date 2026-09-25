import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/models/user_role.dart';
import 'package:stunting_care/screens/child_list_screen.dart';
import 'package:stunting_care/screens/food_diary_screen.dart';
import 'package:stunting_care/screens/home_screen.dart';
import 'package:stunting_care/screens/login_screen.dart';
import 'package:stunting_care/screens/profile_screen.dart';
import 'package:stunting_care/screens/recipe_list_screen.dart';
import 'package:stunting_care/services/auth_service.dart';
import 'package:stunting_care/services/child_service.dart';
import 'package:stunting_care/services/food_diary_service.dart';
import 'package:stunting_care/services/recipe_service.dart';

Widget _host(Widget child) => MaterialApp(home: child);

Future<void> _useTallSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    AuthService().logout();
    FoodDiaryService().clear();
    ChildService().resetDemoData();
  });

  testWidgets('Login demo yang benar membuka Home', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(_host(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('MASUK SEKARANG'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Diva Putri Adilla'), findsOneWidget);
  });

  testWidgets('Login dengan password salah ditolak', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(_host(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'password-salah');
    await tester.tap(find.text('MASUK SEKARANG'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.textContaining('tidak cocok'), findsOneWidget);
  });

  testWidgets('Kader melihat 20 data anak dan bisa menambah data', (
    tester,
  ) async {
    await _useTallSurface(tester);
    AuthService().setCurrentUser(
      AuthService.demoUserForRole(UserRole.kaderPosyandu),
    );
    await tester.pumpWidget(_host(const ChildListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('20 data anak'), findsOneWidget);

    await tester.tap(find.text('Tambah Anak'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ananda-test');
    await tester.enterText(fields.at(1), 'Ibu Test');
    await tester.enterText(fields.at(2), '9.5');
    await tester.enterText(fields.at(3), '75.0');
    final saveButton = find.widgetWithText(ElevatedButton, 'Tambah Data Anak');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Ananda-test'), findsOneWidget);
    expect(ChildService().getChildren('usr_03').length, 21);
    expect(find.text('21 data anak'), findsOneWidget);
  });

  testWidgets('Porsi negatif ditolak pada Food Diary', (tester) async {
    await _useTallSurface(tester);
    AuthService().setCurrentUser(
      AuthService.demoUserForRole(UserRole.ibuBalita),
    );
    await tester.pumpWidget(_host(const FoodDiaryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah Makanan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ayam Goreng'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '-50');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Tambahkan ke'));
    await tester.pumpAndSettle();

    expect(
      find.text('Masukkan porsi antara 1 sampai 2000 gram'),
      findsOneWidget,
    );
  });

  testWidgets('Filter kategori resep benar-benar menyaring data', (
    tester,
  ) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(_host(const RecipeListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Bubur Ikan Dori'), findsOneWidget);
    expect(find.text('Bubur Ubi Ungu'), findsOneWidget);

    await tester.tap(find.text('Makan Siang'));
    await tester.pumpAndSettle();

    expect(find.text('Nasi Tim Ayam'), findsOneWidget);
    expect(find.text('Bubur Ikan Dori'), findsNothing);
  });

  testWidgets('Bookmark dari detail resep tersinkron di service', (
    tester,
  ) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(_host(const RecipeListScreen()));
    await tester.pumpAndSettle();

    final service = RecipeService();
    final before = service.findById('1')!.bookmarked;

    await tester.tap(find.text('Bubur Ikan Dori'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byIcon(before ? Icons.bookmark : Icons.bookmark_border),
    );
    await tester.pumpAndSettle();

    expect(service.findById('1')!.bookmarked, !before);
  });

  testWidgets('Edit entry Food Diary memperbarui nilai gizi', (tester) async {
    await _useTallSurface(tester);
    final user = AuthService.demoUserForRole(UserRole.ibuBalita);
    AuthService().setCurrentUser(user);
    final diary = FoodDiaryService()..resetDemoData();
    final before = diary
        .getEntries(userId: user.id, date: DateTime.now())
        .first;

    await tester.pumpWidget(_host(const FoodDiaryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '100');
    await tester.pumpAndSettle();
    final saveButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final after = diary
        .getEntries(userId: user.id, date: DateTime.now())
        .firstWhere((e) => e.id == before.id);
    expect(after.portionGram, 100);
    expect(after.calories, lessThan(before.calories));
  });

  testWidgets('Profil memuat pengaturan dan shortcut data', (tester) async {
    await _useTallSurface(tester);
    AuthService().setCurrentUser(
      AuthService.demoUserForRole(UserRole.ibuBalita),
    );
    await tester.pumpWidget(_host(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Profil & Pengaturan'), findsOneWidget);
    expect(find.text('Pengingat Harian'), findsOneWidget);
    expect(find.text('Data Anak'), findsOneWidget);
    expect(find.text('Food Diary'), findsOneWidget);
  });
}
