// Basic Flutter widget tests for Catat Cuan app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/presentation/app/app_widget.dart';

void main() {
  testWidgets('App widget builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AppWidget(),
      ),
    );

    // Verify that the initialization screen is shown
    expect(find.text('Catat Cuan'), findsOneWidget);
    expect(find.text('Menyiapkan aplikasi...'), findsOneWidget);
  });
}
