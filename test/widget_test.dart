import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/main.dart';

void main() {
  testWidgets('App starts with NURI splash branding', (tester) async {
    await tester.pumpWidget(const NuriApp());
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('NURI'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 3000));
  });
}
