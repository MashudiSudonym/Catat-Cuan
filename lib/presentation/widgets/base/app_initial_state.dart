import 'package:flutter/material.dart';

/// Initial/placeholder state widget
/// Provides a minimal placeholder for initial states
class AppInitial extends StatelessWidget {
  const AppInitial({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
