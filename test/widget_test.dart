import 'package:flutter_test/flutter_test.dart';
import 'package:intellilotto/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that chat screen is loaded
    expect(find.text('輸入訊息...'), findsOneWidget);
  });
}
