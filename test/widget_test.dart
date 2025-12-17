/// Payday App Tests
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/main.dart';

void main() {
  testWidgets('Payday app initializes smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PaydayApp(),
      ),
    );

    // Verify the splash screen shows
    expect(find.text('Payday'), findsOneWidget);
    expect(find.text('Your Money Countdown Starts Now'), findsOneWidget);
  });
}
