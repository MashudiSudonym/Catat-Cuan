import 'package:flutter/material.dart';

class SavingsGoalDetailScreen extends StatelessWidget {
  const SavingsGoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Goal')),
      body: const Center(child: Text('Detail placeholder')),
    );
  }
}
