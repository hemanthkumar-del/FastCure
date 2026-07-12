import 'package:flutter_test/flutter_test.dart';
import 'package:fastcure/main.dart';

void main() {
  testWidgets('FastCureApp widget smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FastCureApp());

    // Verify that the app starts up without throwing exceptions
    expect(tester.takeException(), isNull);
  });
}
