import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing SharedPreferences operations
/// Following SRP: Only handles shared preferences storage
class SharedPreferencesService {
  /// Key for tracking onboarding visibility
  static const String _onboardingKey = 'show_onboarding';

  /// Key for last backup date (ISO 8601 string)
  static const String _lastBackupDateKey = 'last_backup_date';

  /// Key for connected Google account email
  static const String _connectedAccountEmailKey = 'connected_account_email';

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

  /// Get last backup date as ISO 8601 string
  /// Per D-17: Displayed in Settings screen
  Future<String?> getLastBackupDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastBackupDateKey);
    } catch (e) {
      return null;
    }
  }

  /// Set last backup date as ISO 8601 string
  Future<void> setLastBackupDate(String isoDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastBackupDateKey, isoDate);
    } catch (e) {
      // Silently fail
    }
  }

  /// Get connected Google account email
  /// Per D-11: Displayed in Settings screen
  Future<String?> getConnectedAccountEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_connectedAccountEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Set connected Google account email
  Future<void> setConnectedAccountEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_connectedAccountEmailKey, email);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all backup metadata (for sign-out)
  Future<void> clearBackupMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastBackupDateKey);
      await prefs.remove(_connectedAccountEmailKey);
    } catch (e) {
      // Silently fail
    }
  }
}
