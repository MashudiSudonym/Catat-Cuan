import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({
    super.key,
    this.onCompletion,
  });

  final VoidCallback? onCompletion;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    _controller.play();
    widget.onCompletion?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _controller,
      blastDirection: pi / 2,
      blastDirectionality: BlastDirectionality.directional,
      maxBlastForce: 20,
      minBlastForce: 5,
      emissionFrequency: 0.05,
      numberOfParticles: 30,
      gravity: 0.3,
      colors: const [
        AppColors.primary,
        AppColors.success,
        AppColors.warning,
        AppColors.info,
      ],
    );
  }
}
