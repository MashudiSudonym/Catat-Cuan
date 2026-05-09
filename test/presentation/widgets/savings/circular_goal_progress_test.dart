import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/presentation/widgets/savings/circular_goal_progress.dart';

void main() {
  group('CircularGoalProgress', () {
    Widget buildWidget({required double percentage, required bool isDark}) {
      return MaterialApp(
        home: Scaffold(
          body: CircularGoalProgress(
            percentage: percentage,
            isDark: isDark,
          ),
        ),
      );
    }

    testWidgets('renders at 0% progress', (tester) async {
      await tester.pumpWidget(buildWidget(percentage: 0, isDark: false));
      await tester.pumpAndSettle();

      expect(find.text('0%'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders at 25% progress', (tester) async {
      await tester.pumpWidget(buildWidget(percentage: 25, isDark: false));
      await tester.pumpAndSettle();

      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('renders at 50% progress', (tester) async {
      await tester.pumpWidget(buildWidget(percentage: 50, isDark: false));
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('renders at 75% progress', (tester) async {
      await tester.pumpWidget(buildWidget(percentage: 75, isDark: false));
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('renders at 100% progress', (tester) async {
      await tester.pumpWidget(buildWidget(percentage: 100, isDark: false));
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpWidget(buildWidget(percentage: 50, isDark: true));
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('hides center text when showCenterText is false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CircularGoalProgress(
            percentage: 50,
            isDark: false,
            showCenterText: false,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsNothing);
    });
  });
}
