import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:catat_cuan/presentation/models/onboarding_page_data.dart';
import 'package:catat_cuan/presentation/providers/onboarding/onboarding_provider.dart';
import 'package:catat_cuan/presentation/widgets/onboarding_page.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/main.dart';

/// Onboarding screen with 3 pages showcasing app features
/// Uses PageView for swipe navigation and SmoothPageIndicator for page dots
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // PageView with onboarding pages
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingPages.length,
              itemBuilder: (context, index) {
                return OnboardingPage(data: onboardingPages[index]);
              },
            ),

            // Skip button (top right)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: _buildSkipButton(),
            ),

            // Bottom section with page indicator and action button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSection(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build skip button
  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _handleSkip,
      child: Text(
        'Lewati',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build bottom section with page indicator and action button
  Widget _buildBottomSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassContainer.glassSurface(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: onboardingPages.length,
              effect: WormEffect(
                dotWidth: 10,
                dotHeight: 10,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),

            AppSpacingWidget.verticalXL(),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
                child: Text(
                  _currentPage == onboardingPages.length - 1 ? 'Mulai' : 'Lanjut',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle skip button press
  void _handleSkip() {
    // Skip without marking as seen - will show again on next launch
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  /// Handle next/start button press
  void _handleNext() {
    if (_currentPage == onboardingPages.length - 1) {
      // Last page - complete onboarding and navigate to home
      ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Go to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
