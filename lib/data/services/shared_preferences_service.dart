import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing SharedPreferences operations
/// Following SRP: Only handles shared preferences storage
class SharedPreferencesService {
  /// Key for tracking onboarding visibility
  static const String _onboardingKey = 'show_onboarding';

  /// Check if user has seen onboarding
  /// Returns true if onboarding has been seen, false otherwise
  Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      // Return false (show onboarding) if there's an error
      return false;
    }
  }

  /// Mark onboarding as seen
  Future<void> setOnboardingSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      // Silently fail - app will show onboarding again on next launch
    }
  }

  /// Reset onboarding state (for testing purposes)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, false);
    } catch (e) {
      // Silently fail
    }
  }
}
