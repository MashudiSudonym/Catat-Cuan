/// Route path constants
/// Following SRP: Centralized route definitions
class AppRoutes {
  // Standalone routes
  static const String onboarding = '/onboarding';
  static const String transactions = '/transactions';
  static const String summary = '/summary';

  // Transaction routes (full-screen)
  static const String addTransaction = '/transactions/add';
  static const String editTransaction = '/transactions/edit';
  static const String scanReceipt = '/transactions/scan';

  // Category routes (full-screen)
  static const String categories = '/summary/categories';
  static const String addCategory = '/summary/categories/add';
  static const String editCategory = '/summary/categories/edit';

  // Settings (full-screen)
  static const String settings = '/settings';

  // Helper to generate edit transaction route with ID
  static String editTransactionPath(int id) => '$editTransaction/$id';

  // Helper to generate edit category route with ID
  static String editCategoryPath(int id) => '$editCategory/$id';
}
