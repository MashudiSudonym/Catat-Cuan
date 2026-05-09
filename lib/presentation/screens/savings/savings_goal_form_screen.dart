import 'package:flutter/material.dart';

class SavingsGoalFormScreen extends StatelessWidget {
  const SavingsGoalFormScreen({super.key, this.goalId});

  final int? goalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goalId != null ? 'Edit Goal Tabungan' : 'Buat Goal Tabungan'),
      ),
      body: const Center(child: Text('Form placeholder')),
    );
  }
}
