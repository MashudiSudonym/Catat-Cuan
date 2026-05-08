import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/presentation/widgets/budget/budget_progress_bar.dart';

void main() {
  group('BudgetProgressBar', () {
    Widget buildWidget(double progressPercent) {
      return MaterialApp(
        home: Scaffold(
          body: BudgetProgressBar(
            progressPercent: progressPercent,
            height: 8.0,
          ),
        ),
      );
    }

    testWidgets('shows green color at 50% progress', (tester) async {
      await tester.pumpWidget(buildWidget(50));

      final finder = find.byType(BudgetProgressBar);
      expect(finder, findsOneWidget);

      final widget = tester.widget<BudgetProgressBar>(finder);
      expect(widget.progressColor, Colors.green.shade400);
    });

    testWidgets('shows yellow color at 80% progress', (tester) async {
      await tester.pumpWidget(buildWidget(80));

      final finder = find.byType(BudgetProgressBar);
      expect(finder, findsOneWidget);

      final widget = tester.widget<BudgetProgressBar>(finder);
      expect(widget.progressColor, Colors.orange.shade400);
    });

    testWidgets('shows red color at 120% progress', (tester) async {
      await tester.pumpWidget(buildWidget(120));

      final finder = find.byType(BudgetProgressBar);
      expect(finder, findsOneWidget);

      final widget = tester.widget<BudgetProgressBar>(finder);
      expect(widget.progressColor, Colors.red.shade400);
    });

    testWidgets('shows green color at zero progress', (tester) async {
      await tester.pumpWidget(buildWidget(0));

      final finder = find.byType(BudgetProgressBar);
      expect(finder, findsOneWidget);

      final widget = tester.widget<BudgetProgressBar>(finder);
      expect(widget.progressColor, Colors.green.shade400);
    });

    testWidgets('shows green at exactly 75%', (tester) async {
      await tester.pumpWidget(buildWidget(75));

      final finder = find.byType(BudgetProgressBar);
      final widget = tester.widget<BudgetProgressBar>(finder);
      // Exactly 75% should still be green (threshold is >75)
      expect(widget.progressColor, Colors.green.shade400);
    });

    testWidgets('shows yellow at exactly 76%', (tester) async {
      await tester.pumpWidget(buildWidget(76));

      final finder = find.byType(BudgetProgressBar);
      final widget = tester.widget<BudgetProgressBar>(finder);
      expect(widget.progressColor, Colors.orange.shade400);
    });

    testWidgets('shows yellow at exactly 100%', (tester) async {
      await tester.pumpWidget(buildWidget(100));

      final finder = find.byType(BudgetProgressBar);
      final widget = tester.widget<BudgetProgressBar>(finder);
      expect(widget.progressColor, Colors.orange.shade400);
    });

    testWidgets('shows red at exactly 101%', (tester) async {
      await tester.pumpWidget(buildWidget(101));

      final finder = find.byType(BudgetProgressBar);
      final widget = tester.widget<BudgetProgressBar>(finder);
      expect(widget.progressColor, Colors.red.shade400);
    });
  });
}
