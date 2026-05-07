/// Route path constants
/// Following SRP: Centralized route definitions
class AppRoutes {
  // Standalone routes
  static const String onboarding = '/onboarding';
  static const String transactions = '/transactions';
  static const String reports = '/reports';

  // Transaction routes (full-screen)
  static const String addTransaction = '/transactions/add';
  static const String editTransaction = '/transactions/edit';
  static const String scanReceipt = '/transactions/scan';

  // Category routes (full-screen, nested under reports)
  static const String categories = '/reports/categories';
  static const String addCategory = '/reports/categories/add';
  static const String editCategory = '/reports/categories/edit';

  // Settings (full-screen)
  static const String settings = '/settings';

  // Helper to generate edit transaction route with ID
  static String editTransactionPath(int id) => '$editTransaction/$id';

  // Helper to generate edit category route with ID
  static String editCategoryPath(int id) => '$editCategory/$id';
}
