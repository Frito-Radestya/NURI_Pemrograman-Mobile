import 'package:flutter_test/flutter_test.dart';

import 'package:nuri_app/app.dart';

void main() {
  testWidgets('NURI app renders the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NuriApp());
    await tester.pump();

    expect(find.text('nuri'), findsWidgets);
  });
}
