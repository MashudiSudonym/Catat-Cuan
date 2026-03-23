import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/models/onboarding_page_data.dart';
import 'package:catat_cuan/presentation/widgets/onboarding_illustration.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Single onboarding page widget
/// Displays illustration, title, and subtitle with proper spacing
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.all(AppSpacing.xxl),
      child: Column(
        children: [
          // Illustration at top (40% of screen)
          OnboardingIllustration(data: data),

          AppSpacingWidget.verticalXXXL(),

          // Title
          Text(
            data.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
            textAlign: TextAlign.center,
          ),

          AppSpacingWidget.verticalLG(),

          // Subtitle
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
