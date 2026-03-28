import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:catat_cuan/presentation/models/onboarding_page_data.dart';
import 'package:catat_cuan/presentation/providers/onboarding/onboarding_provider.dart';
import 'package:catat_cuan/presentation/providers/onboarding/category_seeding_provider.dart';
import 'package:catat_cuan/presentation/widgets/onboarding_page.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';

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
  bool _isSeeding = false;

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

            // Loading overlay during seeding
            if (_isSeeding) _buildSeedingOverlay(),
          ],
        ),
      ),
    );
  }

  /// Build loading overlay shown during category seeding
  Widget _buildSeedingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: AppGlassContainer.glassCard(
          child: Padding(
            padding: AppSpacing.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                AppSpacingWidget.verticalMD(),
                Text(
                  'Menyiapkan data...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build skip button
  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isSeeding ? null : _handleSkip,
      child: Text(
        'Lewati',
        style: TextStyle(
          color: _isSeeding
              ? AppColors.textSecondary.withValues(alpha: 0.5)
              : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build bottom section with page indicator and action button
  Widget _buildBottomSection() {
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
                onPressed: _isSeeding ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
                child: _isSeeding
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _currentPage == onboardingPages.length - 1
                            ? 'Mulai'
                            : 'Lanjut',
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
    _performSeedingAndNavigate();
  }

  /// Handle next/start button press
  void _handleNext() {
    if (_currentPage == onboardingPages.length - 1) {
      // Last page - seed categories and navigate to home
      _performSeedingAndNavigate();
    } else {
      // Go to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Seed default categories and navigate to the main app
  Future<void> _performSeedingAndNavigate() async {
    if (_isSeeding) return;

    setState(() {
      _isSeeding = true;
    });

    try {
      // Mark onboarding as seen
      await ref.read(onboardingProvider.notifier).completeOnboarding();

      // Seed default categories
      await ref.read(categorySeedingProvider.notifier).seedCategories();

      if (mounted) {
        context.go(AppRoutes.transactions);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to seed categories', e, stackTrace);
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessageMapper.getUserMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
